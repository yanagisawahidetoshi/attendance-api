require 'rails_helper'
require 'faker'

RSpec.describe V1::UsersController, type: :controller do
  let(:companies) { create_list(:company, 2) }

  describe 'GET #index' do
    context 'normalUser' do
      before do
        create_list(:user, 9, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      it 'ユーザ一覧が取得できること' do
        per_page = 3
        get :index, params: {page: 1, per_page: per_page, company_id: User.first.company_id}
        body = JSON.parse(response.body)
        expect(body['users'].length).to eq per_page
        expect(response.body).to include User.first.name
        expect(body['total']).to eq User.all.size.to_i / per_page
      end

      it '他の会社のユーザ一覧は取得できないこと' do
        get :index, params: {page: 1, per_page: 3, company_id: companies.last.id}
        expect(response.body).to include '会社IDが間違っています'
        expect(response.body).not_to include 'users'
        expect(response.status).to eq 400
      end
    end

    context 'admin' do
      before do
        create(:user, :admin)
        request.headers['Authorization'] = User.first.access_token
      end
      let(:users) { create_list(:user, 9, company_id: companies.first.id) }

      it 'ユーザ一覧が取得できること' do
        users
        per_page = 3
        get :index, params: {page: 1, per_page: per_page, company_id: users.first.company_id}
        body = JSON.parse(response.body)
        expect(body['users'].length).to eq per_page
        expect(response.body).to include users.first.name
        expect(body['total']).to eq users.size.to_i / per_page
      end
    end
  end
end
