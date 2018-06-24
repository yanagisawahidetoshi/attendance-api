require 'rails_helper'
require 'faker'

RSpec.describe V1::UsersController, type: :controller do
  let(:companies) { create_list(:company, 2) }

  describe 'DELETE #delete' do
    context 'normalUser' do
      before do
        create_list(:user, 9, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      it '削除できないこと' do
        params = {id: User.first.id, name: Faker::Name.name, company_id: User.first.company_id}
        delete :delete, params: params
        expect(response.status).to eq 400
        expect(response.body).to include '権限がありません'
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
        delete :delete
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end
      
      it '自分自身を削除できること' do
        params = {id: User.first.id, company_id: User.first.company_id}
        delete :delete, params: params
        expect(response).to be_successful
        expect(User.find_by_id(params[:id])).to eq nil
      end

      it '他人を更新でること' do
        params = {id: user.id, company_id: user.company_id}
        delete :delete, params: params
        expect(response).to be_successful
        expect(User.find_by_id(params[:id])).to eq nil
      end

      it '他の会社のユーザは更新できないこと' do
        params = {id: other_company_user.id, company_id: other_company_user.company_id}
        delete :delete, params: params
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
        params = {id: User.first.id}
        delete :delete, params: params
        expect(response).to be_successful
        expect(User.find_by_id(params[:id])).to eq nil
      end

      it '他人を更新でること' do
        params = {id: user.id, company_id: user.company_id}
        delete :delete, params: params
        expect(response).to be_successful
        expect(User.find_by_id(params[:id])).to eq nil
      end
    end
  end
end