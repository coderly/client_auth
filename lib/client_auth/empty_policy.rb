require 'client_auth/policy'

module ClientAuth
  class EmptyPolicy < Policy
    def authorization
      Authorization.new(true, false)
    end
  end
end