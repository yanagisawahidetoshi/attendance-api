# frozen_string_literal: true

module V1
  class CompaniesController < ApplicationController
    before_action :check_auth
    before_action :valid_id, only: %i[update delete]

    def index
      companies = Company.page(params[:page]).per(params[:per_page])
      total = Company.page.total_pages
      render json: { companies: companies, total: total }
    end

    def create
      company = Company.create(strong_params)
      unless company.valid?
        render_bad_request(company.errors.full_messages) && return
      end

      render json: { company: company }
    end

    def update
      @company.update(strong_params)
      render json: { company: @company }
    end

    def delete
      @company.destroy
    end

    private

    def check_auth
      render_bad_request('権限がありません') && return unless is_admin
    end

    def valid_id
      render_bad_request('IDを入力してください') && return if strong_params[:id].nil?
      @company = Company.find_by(id: strong_params[:id])

      return unless @company.nil?

      render_bad_request('IDが見つかりません') && return
    end

    def strong_params
      params.permit(:id, :name, :zip, :tel, :address)
    end
  end
end
