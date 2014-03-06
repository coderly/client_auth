require 'spec_helper'
require 'client_auth/token_auth'


describe ClientAuth::TokenAuth do
  
  let(:token_auth){ ClientAuth::TokenAuth.new(params) }
  
  subject{ token_auth }
  
  before do
    create(:user, token: 'abcd', name: 'test_user')
  end
  
  describe "when device doesnt exists" do
    
    let(:device_token){ ClientAuth::TokenAuth.new({token: 'abcd', client_id: '123'}).login }
        
    let(:params){ { token: device_token } }
    
    its("current_user.name"){ should eq 'test_user'}
    
    its("current_device.key"){ should eq '123'}
    
    
  end
end