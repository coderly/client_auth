require 'rails/generators/migration'
require 'rails/generators/active_record'

class DevicesAuth::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  desc "generates device model migration"
  
  source_root File.expand_path('../../../../db/migrate', __FILE__) 
 
  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end
  
  
  def generate_migration
      migration_template 'create_devices.rb', 'db/migrate/create_devices'
  end
end