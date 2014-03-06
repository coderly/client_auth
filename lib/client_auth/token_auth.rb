require File.dirname(__FILE__) + '/../../app/models/client_auth/client'
module ClientAuth
  class TokenAuth
    
    DEVISE_TOKEN_LENGTH = 20

    def initialize(params)
      @params = params
    end

    def applicable?(action)
      case action
        when :login
          params.include? :client_id
        when :authenticate, :logout
          token.length == DEVISE_TOKEN_LENGTH
        else
          raise "Unknown action #{action}"
      end
    end

    def login
      user = resource_class.find_by(resource_key => token)

      device = ClientAuth::Client.find_or_create_for_key(client_id)
      device.assign(user)

      device.token
    end

    def logout
      current_device.deactivate
      current_device.regenerate_auth_token
    end

    def authenticated?
      !!current_user
    end

    def current_user
      current_device.try(:owner)
    end

    private

    attr_reader :params

    def current_device
      ClientAuth::Client.find_by(token: token)
    end

    def token
      params[:token]
    end

    def client_id
      params[:client_id]
    end
    
    def resource_class
      ClientAuth.devices_owner_model.to_s.capitalize.constantize
    end
    
    def resource_key
      ClientAuth.devices_owner_key
    end
    
  end
end