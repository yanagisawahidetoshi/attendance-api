# frozen_string_literal: true

class Company < ApplicationRecord
  VALID_ZIP_REGEX = /\A[0-9]{3}-?[0-9]{4}\Z/i
  VALID_TEL_REGEX = /\A0\d{1,4}-?\d{1,4}-?\d{3,4}\Z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: { maximum: 32 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :zip, length: { maximum: 8 },
                  format: { with: VALID_ZIP_REGEX }, allow_nil: true
  validates :tel, length: { maximum: 13 },
                  format: { with: VALID_TEL_REGEX }, allow_nil: true
  validates :address, length: { maximum: 64 }
end
