# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :company

  validates :card_id, presence: true, length: { maximum: 64 }
  validates :token, length: { is: 32 }

  scope :search_card_id, ->(card_id) { where(card_id: card_id) }
end
