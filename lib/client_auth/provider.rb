require File.dirname(__FILE__) + '/provider/anonymous'
require File.dirname(__FILE__) + '/provider/basic'
require 'client_auth/basic_identity'
module ClientAuth
  module Provider

    MissingProviderError = Class.new(StandardError)

    def self.lookup(name)
      class_name = name.to_s.camelize
      raise MissingProviderError, "Can't find provider #{class_name} for #{name}" unless const_defined?(class_name)

      const_get(class_name).new
    end
    
    def self.lookup_identity_model(name)
      class_name = "#{name}_identity".camelize
      ClientAuth.const_get(class_name)
    rescue NameError
      ClientAuth::Identity
    end
    

  end
end
