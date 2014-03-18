require "rack/test"
require 'client_auth/api'
require 'json'
require 'hashie/mash'
require 'pry'
require 'spec_helper'

module ClientAuth
  describe 'permissions for an api' do

    class TestPolicy

      def initialize(current_user, role)
        @current_user = current_user
        @role = role
      end

      def get?
        @role == 'moderator'
      end

    end

    class TestAPI < Grape::API

      helpers ClientAuth::Helpers

      helpers do
        def current_user
          {name: 'john', role: params[:role]}
        end
      end

      params do
        requires :role, type: String
      end
      get 'test' do
        authenticate! TestPolicy, params[:role]
      end

    end

    def app
      TestAPI
    end

    it 'should fail with the wrong password' do
      get 'test', {role: 'abcd'}
      last_response.status.should == 401
    end

    it 'should be successful with the right password' do
      get 'test', {role: 'moderator'}
      last_response.status.should == 200
    end

  end

end