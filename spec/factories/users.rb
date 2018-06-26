# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    authority User.authorities["normal"]
    trait :admin do
      authority User.authorities["admin"]
    end
  end
end
