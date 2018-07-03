class Card < ApplicationRecord
  belongs_to :company

  validates :card_id, presence: true, length: { maximum: 64 }
  validates :token, length: { is: 32 }
end
