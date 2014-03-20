require 'client_auth/empty_policy'

module ClientAuth
  class PolicyResolver

    def self.resolve_class(name)
      return name if name.is_a? Class

      prefix = name.to_s.camelize
      if prefix.empty?
        EmptyPolicy
      else
        const_get("#{prefix}Policy")
      end
    end

  end
end
