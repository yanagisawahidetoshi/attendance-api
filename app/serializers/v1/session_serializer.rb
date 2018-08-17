# frozen_string_literal: true

module V1
  class SessionSerializer < ActiveModel::Serializer
    attributes :email, :authority, :user_id, :access_token

    def user_id
      object.id
    end

    def token_type
      'Bearer'
    end
  end
end
