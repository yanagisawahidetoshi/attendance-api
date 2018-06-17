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
      
      get :index, params: {page: 1, per_page: 20} 
      expect(JSON.parse(response.body)['companies'].length).to eq 20
      expect(response.body).to include companies.first.name
    end
  end
  describe 'POST #create' do
    before do
      create(:user)
      request.headers['Authorization'] = User.first.access_token
    end
    it '400を返すこと' do
      post :create
      expect(response.body).to include '会社名を入力してください'
      expect(response.status).to eq 400
    end
    it '正常な値を返すこと' do
      post :create, params: {name: 'hogehoge'}
      puts response.body
    end
  end

end
