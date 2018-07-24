# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    # skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :check_auth
    before_action :valid_id, only: %i[update delete]

    def index
      users = User
              .where(company_id: params[:company_id])
              .page(params[:page])
              .per(params[:per_page])
      render json: { users: users, total: users.total_pages }
    end

    # POST
    # Create an user
    def create
      render_bad_request('ユーザを作成する権限がありません') && return if is_normal_user

      @user = User.new strong_params

      if @user.save!
        render json: @user, serializer: V1::SessionSerializer, root: nil
      else
        render json: { error: t('user_create_error') },
               status: :unprocessable_entity
      end
    end

    def update
      @user.update(strong_params)
      render json: { user: @user }
    end

    def delete
      render_bad_request('権限がありません') && return if is_normal_user
      @user.destroy
    end

    private

    def strong_params
      params.permit(:id, :name, :email, :password, :company_id, :authority)
    end

    def check_auth
      if is_build_difference_company
        render_bad_request('会社IDが間違っています') && return
      end

      return unless is_company_admin_user && check_params_authority('admin')

      render_bad_request('この権限のユーザを作成する権限がありません') && return
    end

    def valid_id
      render_bad_request('IDを入力してください') && return if strong_params[:id].nil?

      if is_normal_user && different_user_id_for_param
        render_bad_request('更新する権限がありません') && return
      end

      @user = User.find_by(id: strong_params[:id])

      render_bad_request('IDが見つかりません') && return if @user.nil?
    end
  end
end
