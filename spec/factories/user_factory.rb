require 'factory_girl'

FactoryGirl.define do
  factory :user do |user|
    sequence(:name) { |n| "name_#{n}" }
 
    after(:create) do |user|
      user.devices << create(:device, key: "device-for-#{user.id}")
    end

  end
end