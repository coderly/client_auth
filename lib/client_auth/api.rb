require File.dirname(__FILE__) + '/../../app/models/client_auth/client'
require 'client_auth/helpers'
require 'client_auth/service'
require 'client_auth/error/invalid_credentials'
require 'client_auth/error/local_identity_missing'
require 'client_auth/error/already_registered'
require 'grape'

module ClientAuth
  class API < Grape::API
    format :json

    rescue_from Error::InvalidCredentials, Error::LocalIdentityMissing, Error::AlreadyRegistered

    helpers ClientAuth::Helpers

    helpers do
      def auth_service
        ClientAuth::Service.new
      end
    end

    desc 'Get the user who is currently logged in'
    get 'user' do
      authenticate!

      present :id, current_user.id
    end

    resource 'identities' do
      
      desc 'Get the identities of the currently logged in user'
      get do
        identities = ClientAuth::Identity.for_user(current_user)
        present :identities, identities
      end
      
      
      desc 'Connect an identity to the currently logged in user'
      params do
        requires :type, type: String, desc: 'The type of identity (basic, facebook, etc)'
        requires :credentials, type: Object, desc: 'The credentials for the auth provider'
      end
      post ':type/connect' do
        authenticate!

        auth_service.connect(current_user, params[:type], params[:credentials])

        present :success, true
      end

    end

    desc 'Log the current user into the system. This will create an account if one does not exist.'
    params do
      requires :method, type: String, desc: 'The authentication method'
      requires :client_id, type: String, desc: 'A unique identifier of the device making the request'
      requires :credentials, type: Object, desc: 'The credentials for the auth provider'
    end
    post 'register' do
      method, credentials = params[:method], params[:credentials]

      identity = auth_service.register(method, credentials)

      device = ClientAuth::Client.find_or_create_for_key(params[:client_id])
      device.assign(identity.user)

      present :token, device.token
      present :success, true
    end

    desc 'Log the user into the account. This call will fail if no registration was done before.'
    params do
      requires :method, type: String, desc: 'The authentication method'
      requires :client_id, type: String, desc: 'A unique identifier of the device making the request'
      requires :credentials, type: Object, desc: 'The credentials for the auth provider'
    end
    post 'login' do
      method, credentials = params[:method], params[:credentials]

      identity = auth_service.login(method, credentials)

      if identity
        device = ClientAuth::Client.find_or_create_for_key(params[:client_id])

        device.assign(identity.user)

        present :token, device.token
        present :success, true
      else
        present :success, false
      end
    end

  end
end