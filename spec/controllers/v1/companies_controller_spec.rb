# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::CompaniesController, type: :controller do
  describe 'GET #index' do
    before do
      create(:user)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }
    it '正常にレスポンスを返すこと' do
      get :index
      expect(response).to be_successful
    end

    it 'companyが取得されていること' do
      company
      get :index
      expect(response.body).to include company.name
    end
  end
end
