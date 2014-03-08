module ClientAuth
  class Identity < ActiveRecord::Base

    serialize :details, JSON

    self.table_name = 'client_auth_identities'

    belongs_to :user, polymorphic: true
    
    after_create :notify_user_after_create
    after_save :notify_user_after_save

    def self.for_user(user)
      where(user_type: user.class, user_id: user.id).order(:provider)
    end

    def self.for_user_of_type(user, type)
      for_user(user).where(provider: type).first
    end

    def self.has_real_identity?(user)
      for_user(user).not_anonymous.exists?
    end

    def self.not_anonymous
      where( arel_table[:provider].not_in [:anonymous] )
    end

    def has_user?
      !user.nil?
    end

    def associate(user)
      self.user = user
    end

    def detach
      self.user_id = nil
      self.user_type = nil
    end
    
    def as_json(options = {})
      {
          id: id,
          type: provider
      }
    end
    
    private

    def notify_user_after_create
      user.send(:after_identity_create, self) if user.respond_to?(:after_identity_create, true)
    end
    
    def notify_user_after_save
      user.send(:after_identity_save, self) if user.respond_to?(:after_identity_save, true)
    end

  end
end
