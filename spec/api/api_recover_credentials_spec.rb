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
          post 'request-password-reset', {
              type: 'basic',
              credentials: {
                  email: 'neymar@test.com'
               }
          }
        }.to change{PasswordResetRequest.count}.by(1)
        
        request = PasswordResetRequest.last
        expect(request.token).not_to be_blank
        expect(request.expires_at).to eq Time.new(2014, 6, 20, 1)
        expect(request.identity.details['email']).to eq 'neymar@test.com'
        Timecop.return
      end
      
      it 'should call send_forgot_password_email block' do
        fake_mailer = double
        allow(fake_mailer).to receive(:forgot_password)
        ClientAuth.send_forgot_password_email = lambda { |token, user| fake_mailer.forgot_password(user, token) }
        get 'user'
        user = ClientAuth.resource_class.find(json.id)
        PasswordResetRequest.stub(:generate_token) { 'ABC123'}
        
        expect(fake_mailer).to receive(:forgot_password).with(user, 'ABC123')
        post 'request-password-reset', { type: 'basic',  credentials: { email: 'neymar@test.com'} }
      end
      
      it "should change a credential with correct token" do
        post 'request-password-reset', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        request = PasswordResetRequest.last
        post 'reset-password', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        post 'login', { method: 'basic', client_id: 'OTHER', credentials: { email: 'neymar@test.com', password: '456' } }
        expect(json.success).to eq true
      end
      
      it "should raise an error if token's wrong" do
        post 'request-password-reset', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        expect { 
          post 'reset-password', { token: 'abcd', credentials: { email: 'neymar@test.com', password: '456' } }
        }.to raise_error(Error::InvalidRecoverToken)
      end
      
      it "should raise an exception if token's expired" do
        Timecop.freeze(2014, 06, 20)
        post 'request-password-reset', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        request = PasswordResetRequest.last
        Timecop.freeze(2014, 06, 20, 11)
        expect { 
          post 'reset-password', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        }.to raise_error(Error::InvalidRecoverToken)
        Timecop.return
      end
    

      it "should use a token just once" do
        post 'request-password-reset', { type: 'basic', credentials: { email: 'neymar@test.com' } }
        request = PasswordResetRequest.last
        post 'reset-password', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        expect(json.success).to eq true

        expect { 
          post 'reset-password', { token: request.token, credentials: { email: 'neymar@test.com', password: '456' } }
        }.to raise_error(Error::InvalidRecoverToken)
      end

    end
    
  end
  
end