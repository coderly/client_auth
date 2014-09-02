require "client_auth/version"
require 'active_support/core_ext/module'
module ClientAuth
  require 'client_auth/engine' if defined?(Rails)
  
  @@client_id_params = [:client_id, :device_id]
  mattr_accessor :client_id_params
  @@resource_class_name = 'User'
  mattr_accessor :resource_class_name

  mattr_accessor :send_forgot_password_email
  
  class << self
    def setup
      yield self
    end

    def resource_class
      resource_class_name.constantize
    end
  end
  
end
