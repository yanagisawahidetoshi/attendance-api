# frozen_string_literal: true

module V1
  class CompaniesController < ApplicationController
    def index
      companies = Company.page(params[:page]).per(params[:per_page])
      total = Company.page.total_pages
      render json: {companies: companies, total: total}
    end

    def create
      company = Company.create(company_params)
      unless company.valid?
        render status: 400, json: { message: company.errors.full_messages } and return
      end
      
      render json: {company: company}
    end

    def update
      if company_params[:id].nil?
        render status: 400, json: { message: ["IDを入力してください"] } and return
      end
      company = Company.find_by_id(company_params[:id])
      
      if company.nil?
        render status: 400, json: { message: ["IDが見つかりません"] } and return
      end
      
      company.update(company_params)
      render json: {company: company}
    end

    def delete
      if company_params[:id].nil?
        render status: 400, json: { message: ["IDを入力してください"] } and return
      end
      company = Company.find_by_id(company_params[:id])
      if company.nil?
        render status: 400, json: { message: ["IDが見つかりません"] } and return
      end
      company.destroy
      render
    end

    private

    def company_params
      params.permit(:id, :name, :zip, :tel, :address)
    end
  end
end
