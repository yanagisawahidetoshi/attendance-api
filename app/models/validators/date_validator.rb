# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless /\A\d{1,4}\-\d{1,2}\-\d{1,2}\Z/.match?(value.to_s)
      record.errors[attribute] << I18n.t('errors.messages.invalid_date_format')
    end
  end
end
