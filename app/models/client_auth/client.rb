require 'securerandom'
require 'active_record'
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
    
    def self.find_for_token(token)
      find_by(token: token)
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

    def get(key)
      details[key.to_s]
    end

    def set(*args)
      props = args.length == 2 ? {args[0] => args[1]} : args.first
      props.each { |k, v| self.details[k] = v }
      save
    end

    def unset(key)
      self.details.delete(key.to_s)
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