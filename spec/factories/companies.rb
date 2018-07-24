# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    zip { Faker::Address.postcode }
    tel { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
  end
end
