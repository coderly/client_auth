require "devices_auth/version"
require 'active_support/core_ext/module'
module DevicesAuth
  require 'Devices_auth/engine' if defined?(Rails)
  
  @@devices_owner_model = :user
  mattr_accessor :devices_owner_model
  @@devices_owner_key = :token
  mattr_accessor :devices_owner_key
  
  class << self
    def setup
      yield self
    end
  end
  
  
end
