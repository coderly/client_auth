require File.dirname(__FILE__) + '/../../app/models/client_auth/client'
require File.dirname(__FILE__) + '/../../app/models/client_auth/identity'
require File.dirname(__FILE__) + '/../../app/models/client_auth/password_reset_request'

require 'client_auth/provider'
require 'client_auth/provider/anonymous'
require 'client_auth/provider/basic'

require 'client_auth/error'
require 'client_auth/error/invalid_credentials'
require 'client_auth/error/local_identity_missing'
require 'client_auth/error/already_registered'
require 'client_auth/error/invalid_recover_token'

module ClientAuth
  class Service

    def register(type, credentials)
      identity_provider = Provider.lookup(type)
      identity = identity_provider.create_or_update_identity_with_credentials(credentials)

      associate_identity_with_user(identity, create_user)
      identity.save
      identity
    end

    def connect(user, type, credentials)
      identity_provider = Provider.lookup(type)
      identity = identity_provider.create_or_update_identity_with_credentials(credentials)

      associate_identity_with_user(identity, user)

      identity.save
      identity
    end

    def login(type, credentials)
      provider = Provider.lookup(type)
      provider.get_identity_with_credentials(credentials)
    end

    def update_credentials(user, type, credentials)
      identity = Identity.for_user_of_type(user, type)
      raise Error::LocalIdentityMissing, "Local #{type} identity missing" if identity.nil?
      credentials = identity.details.merge credentials

      provider = Provider.lookup(type)
      identity_details = provider.fetch(Hashie::Mash.new(credentials))
      identity_details = Hashie::Mash.new(identity_details)
      identity.details = identity_details

      identity.provider_user_id = identity_details.provider_user_id
      identity.save
    end
    
    def request_password_reset(type, credentials)
      provider = Provider.lookup(type)
      provider.request_password_reset(credentials)
    end
    
    def reset_password(token, credentials)
      request = PasswordResetRequest.find_by token: token
      raise Error::InvalidRecoverToken, "Unknown token" if request.nil?
      raise Error::InvalidRecoverToken, "Expired token" if request.expires_at < Time.now
      raise Error::InvalidRecoverToken, "Already used token" if request.used

      identity = request.identity
      update_credentials(identity.user, identity.provider, credentials)
      request.update_attribute :used, true
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
      ClientAuth.resource_class.create
    end

  end
end
