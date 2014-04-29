require 'bcrypt'

module ClientAuth
  module Provider

    class Anonymous

      attr_reader :details

      def fetch(credentials)
        {
            name: 'anonymous',
            provider_user_id: credentials.client_id,
            client_id: credentials.client_id
        }
      end

      def verify(identity_details, credentials)
        identity_details.client_id == credentials.client_id
      end

      def create_or_update_identity_with_credentials(credentials)
        credentials = Hashie::Mash.new(credentials)
        identity = Identity.where(provider: 'anonymous', provider_user_id: credentials.client_id).first
        identity = Provider.lookup_identity_model('anonymous').new if identity.nil?

        identity.details = fetch(credentials)
        identity.user = nil
        identity.provider = 'anonymous'
        identity.provider_user_id = credentials.client_id
        identity
      end

    end

  end
end
