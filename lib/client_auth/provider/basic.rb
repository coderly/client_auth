require 'bcrypt'

module ClientAuth
  module Provider

    class Basic

      attr_reader :details

      def fetch(credentials)
        {
          name: 'basic',
          provider_user_id: credentials.email,
          username: credentials.username,
          email: credentials.email,
          password_digest: hash_password(credentials.password)
        }
      end

      def verify(identity_details, credentials)
        verify_password(identity_details.password_digest, credentials.password)
      end

      private

      def hash_password(plain_text_password)
        BCrypt::Password.create(plain_text_password)
      end

      def verify_password(password_digest, plain_text_password)
        BCrypt::Password.new(password_digest) == plain_text_password
      end

    end

  end
end