# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :checkAuth
    
    def index
      
    end

    # POST
    # Create an user
    def create
      @user = User.new user_params

      if @user.save!
        render json: @user, serializer: V1::SessionSerializer, root: nil
      else
        render json: { error: t('user_create_error') }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :company_id)
    end
    
    def checkAuth
      if current_user[:authority] == 3 ||
        (current_user[:authority] == 2 && current_user[:company_id] != params[:company_id])
        render status: 400, json: { message: '権限がありません' } and return
      end

    end
  end
end
