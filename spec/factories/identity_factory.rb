require 'factory_girl'

FactoryGirl.define do
  factory :identity, class: ClientAuth::Identity do |identity|
    provider 'dummy'
    sequence(:provider_user_id) { |n| n }
    association :user, :factory => :user
  end
end