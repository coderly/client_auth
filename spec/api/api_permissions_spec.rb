require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'client_auth/policy'
require 'pry'
require 'spec_helper'

class TestPolicy < ClientAuth::Policy

  def initialize(role)
    @role = role
  end

  def get?
    @role == 'moderator'
  end

  def post?
    @role == 'admin'
  end

end

class LoginPolicy < ClientAuth::Policy
  def post?
    params[:username] == current_user[:username] \
     && params[:password] == current_user[:password]
  end
end

class CustomErrorPolicy < ClientAuth::Policy
  def get?
    deny "Access denied. You are too short."
    deny "This message should not show up because you were already denied because of your height."
    true
  end
end

module ClientAuth
  describe 'permissions for an api' do

    class TestAPI < Grape::API

      helpers ClientAuth::Helpers

      helpers do
        def current_user
          {username: 'john', password: '123', role: params[:role]}
        end
      end

      params do
        requires :role, type: String
      end
      get 'test' do
        authenticate! :test, params[:role]
      end

      get 'foo' do
        authenticate! :test, params[:role]
      end

      post 'other-policy' do
        authenticate! :test, params[:role]
      end

      post 'login' do
        authenticate! :login
      end

      get 'custom-error' do
        authenticate! :custom_error
      end

    end

    def app
      TestAPI
    end

    it 'should fail with the wrong password' do
      get 'test', {role: 'abcd'}
      last_response.status.should == 403
    end

    it 'should be successful with the right password' do
      get 'test', {role: 'moderator'}
      last_response.status.should == 200
    end

    it 'should allow passing in the class itself' do
      get 'foo', {role: 'moderator'}
      last_response.status.should == 200
    end

    it 'should call the right method when post is called' do
      post 'other-policy', {role: 'admin'}
      last_response.status.should == 201
    end

    it 'should be possible to access params from the policy' do
      post 'login', {username: 'john', password: '123'}
      last_response.status.should == 201

      post 'login', {username: 'john', password: '456'}
      last_response.status.should == 403
    end

    it 'should be possible to send custom error messages with policies' do
      get 'custom-error'

      last_response.status.should == 403
      last_response.body.should == "Access denied. You are too short."
    end

  end

end