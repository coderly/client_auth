require 'devices_auth'
require 'active_record'

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ':memory:'
  )
  
  load File.dirname(__FILE__) + '/support/schema.rb'
  
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
  
end