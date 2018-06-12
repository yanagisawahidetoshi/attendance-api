# frozen_string_literal: true

module V1
  class CompaniesController < ApplicationController
    def index
      render json: Company.all, each_serializer: V1::CompanySerializer
    end

    def create; end

    def update; end

    def delete; end
  end
end
