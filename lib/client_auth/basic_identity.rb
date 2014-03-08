module ClientAuth
  class BasicIdentity < ClientAuth::Identity

    def as_json(options = {})
      super.merge(email: email)
    end

    def email
      details['email']
    end

  end
end