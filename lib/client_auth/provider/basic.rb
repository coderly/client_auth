require 'bcrypt'

module ClientAuth
  module Provider

    class Basic

      attr_reader :details

      def fetch(credentials)
        return_hash = {
          name: 'basic',
          provider_user_id: credentials.email,
          email: credentials.email,
        }
        # Update the password if the caller is passing a new one.
        if credentials.has_key?('password')
          return_hash[:password_digest] = hash_password(credentials.password)
        # Otherwise use the existing password.
        elsif credentials.has_key?('password_digest')
          return_hash[:password_digest] = credentials.password_digest
        end
        return_hash
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

        identity.details = fetch(credentials)
        identity.provider = 'basic'
        identity.provider_user_id = credentials.email
        identity
      end

      def get_identity_with_credentials(credentials)
        identity = identity_from_credentials(credentials)
        valid = verify(identity.details, credentials)
        raise Error::InvalidCredentials, "Invalid credentials for basic identity" unless valid

        identity
      end
      
      def request_password_reset(credentials)
        identity = identity_from_credentials(credentials)
        request = CredentialsResetRequest.create(identity: identity, expires_at: Time.now + 36000)
        ClientAuth.send_forgot_password_email.call(request.token, identity.user)
      end

      private
      
      def identity_from_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.find_by(provider: 'basic', provider_user_id: credentials.email)
        raise Error::LocalIdentityMissing, "User missing basic identity" if identity.nil?
        identity
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
