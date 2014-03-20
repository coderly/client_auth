module ClientAuth
  class Policy

    AccessDeniedError = Class.new(StandardError)
    Authorization = Struct.new(:allowed?, :denied?, :error_message)

    DEFAULT_ERROR_MESSAGE = '401 Access Denied'

    attr_accessor :current_user, :params, :request, :route
    attr_reader :error_message

    def authorization
      allowed = public_send("#{request_method}?")
      Authorization.new(allowed, !allowed, DEFAULT_ERROR_MESSAGE)
    rescue AccessDeniedError => e
      Authorization.new(false, true, e.message)
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
