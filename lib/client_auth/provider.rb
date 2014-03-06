module ClientAuth
  module Provider

    MissingProviderError = Class.new(StandardError)

    def self.lookup(name)
      class_name = name.to_s.camelize
      raise MissingProviderError, "Can't find provider #{class_name} for #{name}" unless const_defined?(class_name)

      const_get(class_name).new
    end

  end
end
