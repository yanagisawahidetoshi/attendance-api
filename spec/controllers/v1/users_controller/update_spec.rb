require 'rails_helper'
require 'faker'

RSpec.describe V1::UsersController, type: :controller do
  let(:companies) { create_list(:company, 2) }

  describe 'PUT #update' do
    context 'normalUser' do
      before do
        create_list(:user, 9, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      it '会社IDがない場合400を返すこと' do
        put :update
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end
      
      it '自分自身を更新できること' do
        params = {id: User.first.id, name: Faker::Name.name, company_id: User.first.company_id}
        put :update, params: params
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end
      
      it '他人は更新できないこと' do
        params = {id: User.last.id, name: Faker::Name.name, company_id: User.first.company_id}
        put :update, params: params
        expect(response.body).to include '更新する権限がありません'
        expect(response.status).to eq 400
      end

      it '他の会社のユーザは更新できないこと' do
        params = {id: User.last.id, name: Faker::Name.name, company_id: companies.last.id}
        put :update, params: params
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end
    end

    context 'companyAdmin' do
      before do
        create(:user, :companyAdmin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      let(:user) { create(:user, company_id: companies.first.id) }
      let(:other_company_user) { create(:user, :companyAdmin, company_id: companies.last.id) }

      it '会社IDがない場合400を返すこと' do
        put :update
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end
      
      it '自分自身を更新できること' do
        params = {id: User.first.id, name: Faker::Name.name, company_id: User.first.company_id}
        put :update, params: params
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end
      
      it '他人を更新でること' do
        params = {id: User.last.id, name: Faker::Name.name, company_id: User.first.company_id}
        put :update, params: params
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end

      it '他の会社のユーザは更新できないこと' do
        params = {id: other_company_user.id, name: Faker::Name.name, company_id: other_company_user.company_id}
        put :update, params: params
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end
    end

    context 'admin' do
      before do
        create(:user, :admin)
        request.headers['Authorization'] = User.first.access_token
      end
      let(:user) { create(:user, company_id: companies.first.id) }

      it '自分自身を更新できること' do
        params = {id: User.first.id, name: Faker::Name.name}
        put :update, params: params
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end

      it '他人を更新でること' do
        params = {id: user.id, name: Faker::Name.name, company_id: user.company_id}
        put :update, params: params
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end
    end
  end
end