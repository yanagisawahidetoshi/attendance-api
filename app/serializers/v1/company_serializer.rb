# frozen_string_literal: true

module V1
  class CompanySerializer < ActiveModel::Serializer
    attributes :id, :name, :zip, :tel, :address, :created_at, :updated_at
  end
end
