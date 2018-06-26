# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  after_create :update_access_token!

  validates :email, presence: true
  validates :name, presence: true
  validates :authority, presence: true

  enum user_authority: { admin: 1, company_admin: 2, normal: 3 }

  enum authorities: { admin: 1, company_admin: 2, normal: 3 }
  def update_access_token!
    self.access_token = "#{id}:#{Devise.friendly_token}"
    save
  end
end
