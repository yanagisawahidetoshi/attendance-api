# frozen_string_literal: true

module V1
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: [:create]

    # POST /v1/login
    def create
      @user = User.find_for_database_authentication(email: params[:email])
      return invalid unless @user

      if @user.valid_password?(params[:password])
        sign_in :user, @user
        render json: @user, serializer: SessionSerializer, root: nil
      else
        invalid
      end
    end

    def delete
      User.logout(current_user.id)
      render json: { companies: current_user }
    end

    private

    def invalid
      warden.custom_failure!
      render json: {
        error: t('メールアドレスまたはパスワードが間違っています。')
      }, status: :unauthorized
    end
  end
end
