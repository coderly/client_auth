require 'bcrypt'

module ClientAuth
  module Provider

    class Anonymous

      attr_reader :details

      def verify(identity_details, credentials)
        credentials = Hashie::Mash.new(credentials)
        identity_details = Hashie::Mash.new(identity_details)
        identity_details.client_id == credentials.client_id
      end

      def create_or_update_identity_with_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.where(provider: 'anonymous', provider_user_id: credentials.client_id).first
        identity = Provider.lookup_identity_model('anonymous').new if identity.nil?

        identity.details = fetch_details(credentials)
        identity.user = nil
        identity.provider = 'anonymous'
        identity.provider_user_id = credentials.client_id
        identity
      end

      def get_identity_with_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.where(provider: 'anonymous', provider_user_id: credentials.client_id).first
        raise Error::LocalIdentityMissing, "User missing anonymous identity" if identity.nil?

        valid = verify(identity.details, credentials)
        raise Error::InvalidCredentials, "Invalid credentials for anonymous identity" unless valid

        identity
      end

      private

      def fetch_details(credentials)
        {
            name: 'anonymous',
            provider_user_id: credentials.client_id,
            client_id: credentials.client_id
        }
      end

    end

  end
end
