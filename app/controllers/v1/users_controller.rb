# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    # skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :checkAuth
    before_action :validId, only: [:update, :delete]
    
    def index
      users = User
        .where(company_id: params[:company_id])
        .page(params[:page])
        .per(params[:per_page])
      render json: {users: users, total: users.total_pages}
    end

    # POST
    # Create an user
    def create
      if current_user[:authority] == 3
        render status: 400, json: { message: 'ユーザを作成する権限がありません' } and return
      end

      @user = User.new strong_params

      if @user.save!
        render json: @user, serializer: V1::SessionSerializer, root: nil
      else
        render json: { error: t('user_create_error') }, status: :unprocessable_entity
      end
    end
    
    def update
      @user.update(strong_params)
      render json: {user: @user}
    end

    private

    def strong_params
      params.permit(:id, :name, :email, :password, :company_id, :authority)
    end
    
    def checkAuth
      if (current_user[:authority] == 2 || current_user[:authority] == 3) &&
      current_user[:company_id].to_i != params[:company_id].to_i
        render status: 400, json: { message: '会社IDが間違っています' } and return
      end
      
      if current_user[:authority] == 2 && params[:authority].to_i == 1
        render status: 400, json: { message: 'この権限のユーザを作成する権限がありません' } and return
      end
    end

    def validId
      if strong_params[:id].nil?
        render status: 400, json: { message: ["IDを入力してください"] } and return
      end

      if current_user[:authority] == 3 &&
      current_user[:id].to_i != strong_params[:id].to_i
        render status: 400, json: { message: ["更新する権限がありません"] } and return
      end

      @user = User.find_by_id(strong_params[:id])
      
      if @user.nil?
        render status: 400, json: { message: ["IDが見つかりません"] } and return
      end
    end
  end
end
