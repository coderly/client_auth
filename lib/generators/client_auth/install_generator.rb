require 'rails/generators/migration'
require 'rails/generators/active_record'

class ClientAuth::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  desc "generates device model migration"
  
  source_root File.expand_path('../templates', __FILE__) 
   
  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end
  
  def create_initializer_file
    template 'initializer.rb', 'config/initializers/client_auth.rb'
  end
  
  def generate_migration
    migration_template '../../../../db/migrate/create_client_auth_clients.rb', 'db/migrate/create_client_auth_clients'
    migration_template '../../../../db/migrate/create_client_auth_identities.rb', 'db/migrate/create_client_auth_identities'
    migration_template '../../../../db/migrate/client_auth_credentials_reset_request.rb', 'db/migrate/client_auth_credentials_reset_request'
  end
end