require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'pry'
require 'spec_helper'
require 'timecop'
require 'client_auth/error/invalid_recover_token'

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
        
        ClientAuth.send_forgot_password_email = lambda { |user, token|  }
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
        expect(request.expires_at).to eq Time.new(2014, 06, 20, 10)
        expect(request.identity.details['email']).to eq 'neymar@test.com'
        Timecop.return
      end
      
      it 'should call send_forgot_password_email block' do
        fake_mailer = double
        allow(fake_mailer).to receive(:forgot_password)
        
        ClientAuth.send_forgot_password_email = lambda { |user, token| fake_mailer.forgot_password(user, token) }
        
        expect(fake_mailer).to receive(:forgot_password).once
        post 'recover_credentials', { type: 'basic',  credentials: { email: 'neymar@test.com'} }
      end
      
      it "should change a credential with correct token" do
        post 'recover_credentials', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        request = CredentialsResetRequest.last
        post 'reset_credentials', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        post 'login', { method: 'basic', client_id: 'OTHER', credentials: { email: 'neymar@test.com', password: '456' } }
        expect(json.success).to eq true
      end
      
      it "should raise an error if token's wrong" do
        post 'recover_credentials', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        expect { 
          post 'reset_credentials', { token: 'abcd', credentials: { email: 'neymar@test.com', password: '456' } }
        }.to raise_error(Error::InvalidRecoverToken)
      end
      
      it "should raise an exception if token's expired" do
        Timecop.freeze(2014, 06, 20)
        post 'recover_credentials', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        request = CredentialsResetRequest.last
        Timecop.freeze(2014, 06, 20, 11)
        expect { 
          post 'reset_credentials', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        }.to raise_error(Error::InvalidRecoverToken)
        Timecop.return
      end
    
    end
    
  end
  
end