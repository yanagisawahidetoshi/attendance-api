# frozen_string_literal: true

module V1
  class CompaniesController < ApplicationController
    def index
      companies = Company.page(params[:page]).per(params[:per_page])
      total = Company.page.total_pages
      render json: {companies: companies, total: total}
    end

    def create; end

    def update; end

    def delete; end
  end
end
