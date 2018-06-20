# frozen_string_literal: true
require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::CompaniesController, type: :controller do
  context '権限のあるユーザ' do
    before do
      create(:user, :admin, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }
    let(:companies) { create_list(:company, 100) }

    describe 'GET #index' do
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
      it '400を返すこと' do
        post :create
        expect(response.body).to include '会社名を入力してください'
        expect(response.status).to eq 400
      end
      it '正常に会社が登録されていること' do
        params = {name: '柳沢'}
        post :create, params: params
        expect(Company.find_by(name: params[:name]).present?).to eq true
      end
    end
    
    describe 'PUT #update' do
      it '400を返すこと' do
        put :update
        expect(response.body).to include 'IDを入力してください'
        expect(response.status).to eq 400
      end
      it '正常に会社名が更新されること' do
        company
        companyObj = Company.first
        companyObj.name = 'HOGEHOGEHOGEHOG'
        params = {id: companyObj.id, name: companyObj.name}
        put :update, params: params

        expect(response).to be_successful
        expect(response.body).to include companyObj.name
      end
      it '存在しないidの場合エラーになること' do
        company
        companyObj = Company.last
        params = {id: companyObj.id.to_i + 1, name: companyObj.name}
        put :update, params: params

        expect(response.body).to include 'IDが見つかりません'
        expect(response.status).to eq 400
      end
    end
    
    describe 'DELETE #delete' do
      it '400を返すこと' do
        delete :delete
        expect(response.body).to include 'IDを入力してください'
        expect(response.status).to eq 400
      end
      
      it '存在しないidの場合エラーになること' do
        company
        companyObj = Company.last
        params = {id: companyObj.id.to_i + 1}
        delete :delete, params: params

        expect(response.body).to include 'IDが見つかりません'
        expect(response.status).to eq 400
      end
      
      it '正常に削除されること' do
        company
        companyObj = Company.first
        params = {id: companyObj.id}
        delete :delete, params: params

        expect(response).to be_successful
        expect(Company.find_by_id(companyObj.id)).to eq nil
      end
    end
  end

  context '権限のないユーザ' do
    before do
      create(:user)
      request.headers['Authorization'] = User.first.access_token
    end

    describe 'GET #index' do
      it '権限エラーになること' do
        get :index
        expect(response.body).to include '権限がありません'
      end
    end
  end
end