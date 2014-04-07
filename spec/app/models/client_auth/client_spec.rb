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

      it 'should let you pass in a hash to set multiple values' do
        client.set(a: '123', b: '456')
        client.set(a: 'replaced')

        client.get(:a).should eq 'replaced'
        client.get(:b).should eq '456'
      end

      it 'should let you unset a value' do
        client.set(x: 'xx', y: 'yy')
        client.unset(:x)

        client.get(:x).should be_nil
        client.get(:y).should eq 'yy'
      end

      it 'should allow setting complex data' do
        client.set(:o, {x: 3})
        client.get(:o).should eq({'x' => 3})
      end
    end

  end
end