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
        render status: 400, json: { message: company.errors.full_messages }
      else
        company = Company.create(company_params)
        render json: {company: company}
      end
    end

    def update; end

    def delete; end

    private

    def company_params
      params.permit(:name, :zip, :tel, :address)
    end
  end
end
