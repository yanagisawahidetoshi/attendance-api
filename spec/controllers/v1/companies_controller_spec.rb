# frozen_string_literal: true
require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::CompaniesController, type: :controller do
  describe 'GET #index' do
    before do
      create(:user)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }
    let(:companies) { create_list(:company, 100) }

    it '正常にレスポンスを返すこと' do
      get :index
      expect(response).to be_successful
    end

    it 'companyが取得されていること' do
      companies
      get :index
      expect(response.body).to include companies.first.name
    end
  end
end
