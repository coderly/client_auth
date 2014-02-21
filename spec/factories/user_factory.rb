require 'factory_girl'

FactoryGirl.define do
  factory :user do |user|
    sequence(:name) { |n| "name_#{n}" }
  end
end