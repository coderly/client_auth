require 'securerandom'
module ClientAuth
  class Client < ActiveRecord::Base
    
    self.table_name = 'client_auth_clients'
    
    belongs_to :owner, polymorphic: true

    before_save :ensure_auth_token

    serialize :details, JSON

    ACTIVE = 'active'
    INACTIVE = 'inactive'

    def self.find_or_create_for_key(key)
      where(key: key).first_or_create
    end

    def self.find_for_key(key)
      find_by(key: key)
    end

    def self.for_owner(owner)
      active.where(owner_id: owner.id, owner_type: owner.class.name)
    end

    def self.active
      where(status: ACTIVE)
    end

    def ensure_auth_token
      self.token = generate_auth_token if token.blank?
    end

    def regenerate_auth_token
      self.token = generate_auth_token
      save
    end

    def assign(owner)
      self.owner = owner
      self.status = ACTIVE
      save
    end

    def register_push_token(push_token)
      self.push_token = push_token
      save
    end

    def registered_push_token?
      self.push_token.present?
    end

    def update_details(details)
      self.details = details
      save
    end

    def active?
      status == ACTIVE
    end

    def deactivate
      self.status = INACTIVE
      save
    end

    private

    def generate_auth_token
      SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end

  end
end