# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, date: true
  validates :recess, numericality: :only_integer, allow_blank: true

  before_save :presence_and_rount_time

  scope :search_date, ->(date, user) { where(date: date).where(user: user) }

  def presence_and_rount_time
    self.in_time = round_time(in_time, 'in_time') if in_time.present?
    self.out_time = round_time(out_time, 'out_time') if out_time.present?
  end

  def round_time(time, in_out)
    hour = time.strftime('%H').to_i
    if in_out == 'in_time'
      min = (time.strftime('%M').to_f / 15.to_f).ceil * 15
      if min == 60
        min = 0o0
        hour += 1
      end
    elsif in_out == 'out_time'
      min = (time.strftime('%M').to_f / 15.to_f).floor * 15
    end
    "#{format('%02d', hour)}:#{format('%02d', min)}"
  end

  def recess_hour(in_time, out_time)
    return nil if in_time.blank? || out_time.blank?

    in_time = convert_timestamp(in_time)
    out_time = convert_timestamp(out_time)

    diff_time = (out_time - in_time) / 3600

    if diff_time >= 8
      1
    elsif diff_time >= 6 && diff_time < 8
      0.75
    else
      0
    end
  end

  def convert_timestamp(time)
    return nil if time.blank?
    if time.instance_of?(ActiveSupport::TimeWithZone) ||
       time.instance_of?(DateTime)
      time.to_i
    else
      DateTime.parse(time).to_i
    end
  end

  def build_operating_time(obj)
    return nil if obj.in_time.blank? || obj.out_time.blank?

    in_time = convert_timestamp(obj.in_time)
    out_time = convert_timestamp(obj.out_time)
    recess = obj.recess.presence || 0

    (out_time - in_time) / 3600 - recess
  end
end
