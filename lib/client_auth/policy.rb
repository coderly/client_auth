module ClientAuth
  class Policy

    attr_accessor :current_user, :params, :request, :route

    def authorized?
      public_send("#{request_method}?")
    end

    private

    def request_method
      request.env["REQUEST_METHOD"].downcase
    end

  end
end
