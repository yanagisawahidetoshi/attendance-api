# frozen_string_literal: true

module V1
  class CompaniesController < ApplicationController
    before_action :check_auth
    before_action :valid_id, only: [:update, :delete]
    
    def index
      companies = Company.page(params[:page]).per(params[:per_page])
      total = Company.page.total_pages
      render json: {companies: companies, total: total, currentUser: current_user}
    end

    def create
      company = Company.create(strong_params)
      unless company.valid?
        render status: 400, json: { message: company.errors.full_messages } and return
      end
      
      render json: {company: company}
    end

    def update
      @company.update(strong_params)
      render json: {company: @company}
    end

    def delete
      @company.destroy
    end

    private

    def check_auth
      unless current_user[:authority] == User.authorities["admin"]
        render status: 400, json: { message: '権限がありません' } and return
      end
    end

    def valid_id
      if strong_params[:id].nil?
        render status: 400, json: { message: ["IDを入力してください"] } and return
      end
      @company = Company.find_by_id(strong_params[:id])
      
      if @company.nil?
        render status: 400, json: { message: ["IDが見つかりません"] } and return
      end
    end

    def strong_params
      params.permit(:id, :name, :zip, :tel, :address)
    end
  end
end
