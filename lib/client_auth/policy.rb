module ClientAuth
  class Policy

    AccessDeniedError = Class.new(StandardError)
    Authorization = Struct.new(:allowed?, :error_message) do
      def forbidden?
        !allowed?
      end
      alias_method :denied?, :forbidden?
    end

    DEFAULT_ERROR_MESSAGE = '403 Forbidden'

    attr_accessor :current_user, :params, :request, :route
    attr_reader :error_message

    def authorization
      allowed = public_send("#{request_method}?")
      Authorization.new(allowed, DEFAULT_ERROR_MESSAGE)
    rescue AccessDeniedError => e
      Authorization.new(false, e.message)
    end

    def deny(message = DEFAULT_ERROR_MESSAGE)
      raise AccessDeniedError, message
    end

    private

    def has_error_message?
      error_message.present?
    end

    def request_method
      request.env["REQUEST_METHOD"].downcase
    end

  end
end
