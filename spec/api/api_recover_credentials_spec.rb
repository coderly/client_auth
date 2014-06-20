require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'pry'
require 'spec_helper'

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
        expect{
          post 'recover_credentials', {
              type: 'basic',
              credentials: {
                  email: 'neymar@test.com'
               }
          }
        }.to change{CredentialsResetRequest.count}.by(1)
      end
      
      it 'should send an email' do
        expect{
          post 'recover_credentials', {
              type: 'basic',
              credentials: {
                  email: 'neymar@test.com'
               }
          }
        }.to change{ActionMailer::Base.deliveries.count}.by(1)
      end
    
    end
    
  end
  
end