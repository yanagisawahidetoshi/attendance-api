# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    date '2018-07-15'
    in_time '10:00'
    out_time '19:00'
    recess nil
    rest nil
  end
end
