require File.dirname(__FILE__) + '/../../app/models/client_auth/client'
require File.dirname(__FILE__) + '/../../app/models/client_auth/identity'

require 'client_auth/provider'
require 'client_auth/provider/anonymous'
require 'client_auth/provider/basic'

require 'client_auth/error'
require 'client_auth/error/invalid_credentials'
require 'client_auth/error/local_identity_missing'
require 'client_auth/error/already_registered'

module ClientAuth
  class Service

    def register(method, credentials)
      method = method.to_sym
      credentials = Hashie::Mash.new(credentials)

      identity_details = fetch_identity_details(method, credentials)

      local_identity = find_or_new_local_identity!(method, identity_details)

      verify_identity_credentials!(local_identity, credentials)

      local_identity.user = nil if method == :anonymous
      raise Error::AlreadyRegistered, "Already registered for user #{local_identity.user.id}" if local_identity.has_user?

      local_identity.provider = identity_details.name
      local_identity.provider_user_id = identity_details.provider_user_id
      local_identity.details = identity_details

      user = create_user
      associate_identity_with_user(local_identity, user)
      local_identity.save

      local_identity
    end

    def connect(user, method, credentials)
      method = method.to_sym
      credentials = Hashie::Mash.new(credentials)

      identity_details = fetch_identity_details(method, credentials)

      local_identity = find_or_new_local_identity!(method, identity_details)

      verify_identity_credentials!(local_identity, credentials)

      local_identity.provider = identity_details.name
      local_identity.provider_user_id = identity_details.provider_user_id
      local_identity.details = identity_details

      user = user
      associate_identity_with_user(local_identity, user)
      local_identity.save

      local_identity
    end

    def login(method, credentials)
      method = method.to_sym
      credentials = Hashie::Mash.new(credentials)
      identity_details = fetch_identity_details(method, credentials)

      local_identity = find_local_identity(method, identity_details)
      raise Error::LocalIdentityMissing, "Local #{method} identity missing" if local_identity.nil?

      verify_identity_credentials!(local_identity, credentials)

      raise "Missing user for #{method} identity" unless local_identity.has_user?

      local_identity
    end

    private

    def associate_identity_with_user(local_identity, user)
      local_identity.associate(user)

      anonymous_identity = Identity.for_user_of_type(user, :anonymous)

      if anonymous_identity && local_identity.provider != 'anonymous'
        anonymous_identity.destroy
      end

      local_identity
    end

    def find_local_identity(method, identity_details)
      Identity.where(provider: method, provider_user_id: identity_details.provider_user_id).first
    end

    def new_local_identity(identity_details)
      identity = Provider.lookup_identity_model(identity_details.name).new
      identity.provider = identity_details.name
      identity.provider_user_id = identity_details.provider_user_id
      identity.details = identity_details
      identity
    end

    def fetch_identity_details(method, credentials)
      provider = Provider.lookup(method)
      identity_details = provider.fetch(credentials)
      Hashie::Mash.new(identity_details)
    end

    def find_or_new_local_identity(method, identity_details)
      find_local_identity(method, identity_details) || new_local_identity(identity_details)
    end

    def find_or_new_local_identity!(method, identity_details)
      local_identity = find_or_new_local_identity(method, identity_details)
      raise Error::LocalIdentityMissing, "Local #{method} identity missing" if local_identity.nil?
      local_identity
    end

    def verify_identity_credentials!(local_identity, credentials)
      provider = Provider.lookup(local_identity.provider)
      local_identity_details = Hashie::Mash.new(local_identity.details)
      valid = provider.verify(local_identity_details, credentials)
      raise Error::InvalidCredentials, "Invalid credentials for #{local_identity.provider}" unless valid
    end

    def create_user
      User.create
    end

  end
end
