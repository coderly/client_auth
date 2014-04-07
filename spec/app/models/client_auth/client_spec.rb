require 'spec_helper'

module ClientAuth
  describe Client do

    let(:client) { Client.find_or_create_for_key('CLIENT1234') }

    describe 'metadata' do

      it 'should return nil if a property isnt set' do
        client.get(:missingkey).should be_nil
      end

      it 'should persist when setting a key' do
        client.set(:some_setting, 'abcd')
        client.should be_persisted
      end

      it 'should allow you to fetch back a key' do
        client.set(:some_setting, 'abcd')
        client.get(:some_setting).should eq 'abcd'
      end

      it 'should treat symbols and strings the same' do
        client.set('fruit', 'apple')
        client.get(:fruit).should eq 'apple'

        client.set(:veggie, 'celery')
        client.get('veggie').should eq 'celery'
      end

      it 'should preserve existing keys' do
        client.set(:a, 'letter a')
        client.set(:b, 'letter b')

        client.get(:a).should eq 'letter a'
        client.get(:b).should eq 'letter b'
      end
    end

  end
end