# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    authority User.authorities["normal"]
    trait :admin do
      authority User.authorities["admin"]
    end
    trait :companyAdmin do
      authority 2
    end
  end
end
