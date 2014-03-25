require 'client_auth/policy'

module ClientAuth
  class AllowedPolicy < Policy
    def authorization
      Authorization.new(true)
    end
  end
end