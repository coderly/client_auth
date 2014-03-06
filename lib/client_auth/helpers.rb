require 'base64'

module ClientAuth

  module Helpers

    AUTHORIZATION = "Authorization"
    AUTHORIZATION_TYPE = /^\w+/
    AUTHORIZATION_CREDENTIALS = / .+$/

    def authenticated?
      !!current_user
    end

    def current_user
      device = Client.find_for_token(authorization_token)
      device.try(:owner)
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless authenticated?
    end

    private

    def authorization_type
      headers[AUTHORIZATION][AUTHORIZATION_TYPE]
    end

    def authorization_token
      authorization_username_and_token[1]
    end

    def authorization_username_and_token
      return [] if headers[AUTHORIZATION].nil?
      return [] if headers[AUTHORIZATION][AUTHORIZATION_CREDENTIALS].nil?
      Base64.decode64(headers[AUTHORIZATION][AUTHORIZATION_CREDENTIALS]).split(':').to_a
    end

  end

end