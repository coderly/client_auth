require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'pry'
require 'spec_helper'

module ClientAuth
  describe API do

    def app
      API
    end

    def json
      Hashie::Mash.new JSON.parse(last_response.body)
    end

    describe 'POST register' do

      it 'should create a user account when registering' do
        post 'register', {
            method: 'basic',
            client_id: 'IPHONE123',
            credentials: {
                email: 'doe@hotmail.com',
                password: 'abcd'
            }
        }

        authorize '', json.token
        get 'user'
        json.id.should_not be_nil

        get 'identities'
        json.identities.map(&:type).should eq ['basic']
      end

      it 'should work with other param in client_id params list' do
        post 'register', {
            method: 'basic',
            device_id: 'IPHONE123',
            credentials: {
                email: 'doe@hotmail.com',
                password: 'abcd'
            }
        }

        authorize '', json.token
        get 'user'
        json.id.should_not be_nil

        get 'identities'
        json.identities.map(&:type).should eq ['basic']
      end

      it 'should not allow re-registration' do
        post 'register', {
            method: 'basic',
            client_id: 'IPHONE123',
            credentials: {
                email: 'doe@hotmail.com',
                password: 'abcd'
            }
        }

        post 'register', {
            method: 'basic',
            client_id: 'IPHONE123',
            credentials: {
                email: 'doe@hotmail.com',
                password: 'abcd'
            }
        }

        json.token.should be_nil
        User.count.should eq 1
      end

      context 'when registering with a username, email, and password' do

        before do
          post 'register', {
              method: 'basic',
              client_id: 'APPLE123',
              credentials: {
                  email: 'joe@gmail.com',
                  password: '123'
              }
          }

          @token = json.token
        end

        it 'should allow one to login after registering' do
          post 'login', {
              method: 'basic',
              client_id: 'LOGIN',
              credentials: {
                  email: 'joe@gmail.com',
                  password: '123'
              }
          }

          authorize '', json.token
          get 'user'
          json.id.should_not be_nil
        end

        it 'should not allow a login with an incorrect password' do
          post 'login', {
              method: 'basic',
              client_id: 'LOGIN',
              credentials: {
                  email: 'joe@gmail.com',
                  password: 'moo'
              }
          }

          json.token.should be_nil
        end

        it "should allow you to update your email and password" do
          authorize '', @token
          put 'identities/basic', {
            credentials: {
              email: 'john@doe.com',
              password: 'newpassword'
            }
          }

          get 'identities'
          json.identities.map(&:type).should eq ['basic']
          json.identities[0].email.should eq "john@doe.com"

          post 'login', {
              method: 'basic',
              client_id: 'LOGIN',
              credentials: {
                  email: 'john@doe.com',
                  password: 'newpassword'
              }
          }

          authorize '', json.token
          get 'user'
          json.id.should_not be_nil

        end

      end

      context 'when registering as an anonymous user' do

        before do
          post 'register', {
              method: 'anonymous',
              client_id: 'PEAR1234',
              credentials: {client_id: 'PEAR1234'}
          }

          @token = json.token
          authorize '', @token
        end

        it 'should have created an anonymous identity' do
          get 'identities'
          json.identities.map(&:type).should eq ['anonymous']
        end

        it 'should have created a single device' do
          ClientAuth::Client.count.should eq 1
        end

        it 'should have created a single user' do
          User.count.should eq 1
        end

        context 'when registering a second time' do

          before do
            post 'register', {
                method: 'anonymous',
                client_id: 'PEAR1234',
                credentials: {client_id: 'PEAR1234'}
            }
            @token = json.token
            authorize '', @token
          end

          it 'should not have created a duplicate device' do
            last_response.status.should eq 201

            # we still have one client
            ClientAuth::Client.count.should eq 1

            # it should have created a 2nd anonymous user
            User.count.should eq 2

            # the client got assigned the new owner
            client = ClientAuth::Client.first
            client.owner.should eq User.order(:id).last
          end

        end

        it 'should allow you to create a basic identity' do
          post 'identities/basic/connect', {
              credentials: {
                  email: 'john@doe.com',
                  password: '12345'
              }
          }

          get 'identities'
          json.identities.map(&:type).should eq ['basic'] # anonymous identity gets detached
        end

      end

      it 'should not be possible to login without registering' do
        post 'login', {
            method: 'anonymous',
            client_id: 'PEAR1234',
            credentials: {client_id: 'KANGAROO987'}
        }

        json.token.should be_nil
        User.count.should eq 0
      end

    end

  end
end
