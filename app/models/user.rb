# frozen_string_literal: true

class User < ApplicationRecord
  has_one :card
  devise :database_authenticatable, :registerable, :validatable

  after_create :update_access_token!

  validates :email, presence: true
  validates :name, presence: true
  validates :authority, presence: true

  enum authorities: { admin: 1, company_admin: 2, normal: 3 }

  scope :search_card_id, ->(card_id) { where(card_id: card_id) }
  scope :company_id, ->(id) { find_by(id: id).company_id }
  scope :logout, ->(id) { find_by(id: id).update!(access_token: nil) }
  def update_access_token!
    self.access_token = "#{id}:#{Devise.friendly_token}"
    save
  end
end
