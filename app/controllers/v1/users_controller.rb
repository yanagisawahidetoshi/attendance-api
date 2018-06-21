# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    # skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :checkAuth
    
    def index
      users = User.where(company_id: current_user[:company_id]).page(params[:page]).per(params[:per_page])
      total = User.where(company_id: current_user[:company_id]).page.total_pages
      render json: {users: users, total: total}
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
      params.require(:user).permit(:name, :email, :password, :company_id, :authority)
    end
    
    def checkAuth
      if current_user[:authority] == 3
        render status: 400, json: { message: '権限がありません' } and return
      end

      if current_user[:authority] == 2 && current_user[:company_id].to_i != params[:company_id].to_i
        render status: 400, json: { message: '会社IDが間違っています' } and return
      end

    end
  end
end
