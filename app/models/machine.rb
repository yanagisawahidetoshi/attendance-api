# frozen_string_literal: true

class Machine < ApplicationRecord
  belongs_to :company

  VALID_MACADDRESS_REGEX = /\A([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\Z/i
  validates :mac_address, presence: true, length: { is: 17 },
                          format: { with: VALID_MACADDRESS_REGEX }
  validates :name, presence: false, length: { maximum: 32 }
end
