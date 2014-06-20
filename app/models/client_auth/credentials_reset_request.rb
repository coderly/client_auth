require 'active_record'
require_relative 'identity'

module ClientAuth
  class CredentialsResetRequest < ActiveRecord::Base
    
    self.table_name = 'client_auth_credentials_reset_request'
    
    belongs_to :identity, class_name: "ClientAuth::Identity"

    
  end
end