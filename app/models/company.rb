# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32 }
  validates :zip, length: { maximum: 8 }
  validates :tel, length: { maximum: 13 }
  validates :address, length: { maximum: 64 }
end
