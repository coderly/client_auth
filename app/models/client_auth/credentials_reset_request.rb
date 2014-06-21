require 'active_record'
require 'securerandom'
require_relative 'identity'

module ClientAuth
  class CredentialsResetRequest < ActiveRecord::Base
    
    self.table_name = 'client_auth_credentials_reset_request'
    
    belongs_to :identity, class_name: "ClientAuth::Identity"
    
    before_save :ensure_token
    
    def self.generate_token
      SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end

    def ensure_token
      self.token = self.class.generate_token if token.blank?
    end
    
  end
end