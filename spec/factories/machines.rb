FactoryBot.define do
  factory :machine do
    name { Faker::Name.name }
    mac_address { Faker::Internet.macAddress }
  end
end
