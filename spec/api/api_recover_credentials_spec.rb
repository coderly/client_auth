require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'pry'
require 'spec_helper'
require 'timecop'

module ClientAuth
  
  describe "api recovery for client_auth" do
    
    def app
      API
    end
    
    describe 'for basic auth' do
    
      before do
        post 'register', {
            method: 'anonymous',
            client_id: 'PEAR1234',
            credentials: {client_id: 'PEAR1234'}
        }
        first_token = json.token
      
        authorize '', first_token
        post 'identities/basic/connect', {
            credentials: {
                email: 'neymar@test.com',
                password: '234'
            }
        }
      end
      
      it 'should generate a reset credentials request' do
        Timecop.freeze(2014, 06, 20)
        expect{
          post 'recover_credentials', {
              type: 'basic',
              credentials: {
                  email: 'neymar@test.com'
               }
          }
        }.to change{CredentialsResetRequest.count}.by(1)
        
        request = CredentialsResetRequest.last
        expect(request.token).not_to be_blank
        expect(request.expired_at).to eq Time.new(2014, 06, 20, 12)
        expect(request.identity.user.email).to eq 'neymar@test.com'
      end
      
      it 'should call send_forgot_password_email block' do
        fake_mailer = double
        fake_mailer.stub(:message).with('more_than', 'one_argument')
        allow(fake_mailer).to receive(:forgot_password)
        user = User.find_by email: 'neymar@test.com'
        
        ClientAuth.setup do |config|
          config.send_forgot_password_email = lambda { |user, token| fake_mailer.forgot_password(user, token) }
        end
        
        expect(fake_mailer).to receive(:forgot_password).once
        post 'recover_credentials', { type: 'basic',  credentials: { email: 'neymar@test.com'} }
      end
    
    end
    
  end
  
end