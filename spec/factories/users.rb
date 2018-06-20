# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    authority 3
    trait :admin do
      authority 1
    end
    trait :companyAdmin do
      authority 2
    end
  end
end
