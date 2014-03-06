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

    end

  end
end