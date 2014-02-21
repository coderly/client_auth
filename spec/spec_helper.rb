require 'devices_auth'
require 'active_record'

ENV["RAILS_ENV"] = "test"

require 'factory_girl'
RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ':memory:'
  )
  
  load File.dirname(__FILE__) + '/support/schema.rb'
  
  Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each {|f| require f}
  
  Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| require f}
  
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
  
end