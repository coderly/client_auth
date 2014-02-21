require 'spec_helper'
require 'devices_auth/token_auth'


describe DevicesAuth::TokenAuth do
  before do
    create(:user, token: 'abcd')
  end
end