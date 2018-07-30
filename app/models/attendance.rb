# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, date: true
  validates :recess, numericality: :only_integer, allow_blank: true

  before_save :presence_and_rount_time

  scope :search_date, ->(date, user) { where(date: date).where(user: user) }

  def presence_and_rount_time
    self.in_time = CustomTime.round_time(in_time, 'up') if in_time.present?
    self.out_time = CustomTime.round_time(out_time, 'down') if out_time.present?
  end

  def recess_hour(in_time, out_time)
    return nil if in_time.blank? || out_time.blank?

    diff_time = (conv_timestamp(out_time) - conv_timestamp(in_time)) / 3600

    if diff_time >= 8
      1
    elsif diff_time >= 6 && diff_time < 8
      0.75
    else
      0
    end
  end

  def conv_timestamp(time)
    return nil if time.blank?
    if time.instance_of?(ActiveSupport::TimeWithZone) ||
       time.instance_of?(DateTime)
      time.to_i
    else
      Time.parse(time).to_i
    end
  end

  def build_operating_time(obj)
    return nil if obj.in_time.blank? || obj.out_time.blank?

    in_time = conv_timestamp(obj.in_time)
    out_time = conv_timestamp(obj.out_time)
    recess = obj.recess.presence || 0

    (out_time - in_time) / 3600 - recess
  end
end
