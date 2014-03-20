class PolicyResolver

  class EmptyPolicy
    attr_accessor :current_user, :params, :route

    def initialize(_) end
    def get?; true end
  end

  def self.resolve_class(name)
    return name if name.is_a? Class

    prefix = name.to_s.camelize.capitalize
    if prefix.empty?
      EmptyPolicy
    else
      const_get("#{prefix}Policy")
    end
  end

end
