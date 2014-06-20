require 'client_auth'
require 'active_record'
require 'database_cleaner'
require 'action_mailer'

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
  Dir["#{File.dirname(__FILE__)}/../app/models/client_auth/*.rb"].each {|f| require f}
  
  Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| require f}
  
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  config.include Rack::Test::Methods

  # == Mock Framework
  config.mock_with :rspec
  
  include FactoryGirl::Syntax::Methods
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end
  
  config.before :each do
    DatabaseCleaner.start    
  end
  
  config.after :each do
    DatabaseCleaner.clean
  end
  
  ActionMailer::Base.delivery_method = :test
  
  def json
    Hashie::Mash.new JSON.parse(last_response.body)
  end
  
end