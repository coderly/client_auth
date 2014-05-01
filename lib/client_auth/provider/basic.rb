require 'bcrypt'

module ClientAuth
  module Provider

    class Basic

      attr_reader :details

      def fetch_details(credentials)
        {
          name: 'basic',
          provider_user_id: credentials.email,
          email: credentials.email,
        }
      end

      def verify(identity_details, credentials)
        credentials = Hashie::Mash.new(credentials)
        identity_details = Hashie::Mash.new(identity_details)
        verify_password(identity_details.password_digest, credentials.password)
      end

      def create_or_update_identity_with_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.where(provider: 'basic', provider_user_id: credentials.email).first
        identity = Provider.lookup_identity_model('basic').new if identity.nil?

        raise Error::AlreadyRegistered, "Already registered #{identity.provider_user_id}" if identity.has_user?

        identity.details = {}
        update_identity_details(identity, credentials)

        identity
      end

      def get_identity_with_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.where(provider: 'basic', provider_user_id: credentials.email).first
        raise Error::LocalIdentityMissing, "User missing basic identity" if identity.nil?

        valid = verify(identity.details, credentials)
        raise Error::InvalidCredentials, "Invalid credentials for basic identity" unless valid

        identity
      end

      def update_identity_details(identity, details)
        details = Hashie::Mash.new(details)

        identity.provider = 'basic'

        identity.details['name'] = 'basic'
        identity.details['password_digest'] = hash_password(details.password) if details.has_key?('password')

        if details.has_key?('email') && details.email != identity.provider_user_id
          identity.details['email'] = details.email
          identity.details['provider_user_id'] = details.email
          identity.provider_user_id = details.email
        end
      end

      private

      def identity_exists?(email)
        !Identity.where(provider: 'basic', provider_user_id: email).nil?
      end

      def hash_password(plain_text_password)
        BCrypt::Password.create(plain_text_password)
      end

      def verify_password(password_digest, plain_text_password)
        BCrypt::Password.new(password_digest) == plain_text_password
      end

    end

  end
end
