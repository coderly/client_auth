require 'spec_helper'

module ClientAuth
  describe Identity do
    describe 'callback to user' do
      let(:user){ create(:user) }
      
      describe '#after_identity_create' do
        it "should call after_identity_create on the use when creating the identity" do
          user.should_receive(:after_identity_create).once
          create(:identity, user: user)
        end
      end
      
      describe '#after_identity_create' do
        let!(:identity){ create(:identity, user: user) }
        
        it "should call after_identity_save on the user when the identity is saved" do
          user.should_receive(:after_identity_save).once
          identity.update_attribute :provider, 'test'
        end
        
        it "should not call after_identity_create on the user when identity is saved " do
          user.should_not_receive(:after_identity_create)
          identity.update_attribute :provider, 'test'
        end
        
      end
      
    end
  end
end