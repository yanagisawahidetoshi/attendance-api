# frozen_string_literal: true

FactoryBot.define do
  factory :machine do
    name { Faker::Name.name }
    mac_address { Faker::Internet.mac_address }
  end
end
