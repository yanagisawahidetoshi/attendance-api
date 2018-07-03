FactoryBot.define do
  factory :card do
    card_id { Faker::Crypto.sha256 }
    token { Faker::Crypto.md5 }
  end
end
