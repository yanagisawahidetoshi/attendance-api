require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do
  context '権限のないユーザ' do
    before do
      create(:user, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }

    describe 'GET #index' do
      it '通常ユーザの場合権限エラーになること' do
        get :index
        expect(response.body).to include '権限がありません'
        expect(response.status).to eq 400
      end
    end

    describe 'POST #create' do
      it '通常ユーザの場合権限エラーになること' do
        post :create
        expect(response.body).to include '権限がありません'
        expect(response.status).to eq 400
      end
    end
  end
  
  context '権限のあるユーザ' do
    before do
      create(:user, :companyAdmin, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:users) { create_list(:user, 99, company_id: company.id) }
    let(:company) { create(:company) }
    
    describe 'GET #index' do
      it '異なるcompany_idなら権限エラーになること' do
        get :index, params: {company_id: company.id.to_i + 1}
        expect(response.body).to include '会社IDが間違っています'
        expect(response.status).to eq 400
      end

      it 'usersが取得されていること' do
        users
        get :index, params: {page: 1, per_page: 20, company_id: User.first.company_id}
        expect(JSON.parse(response.body)['users'].length).to eq 20
        expect(response.body).to include User.first.name
      end

      it 'usersの最後のページが取得されていること' do
        users
        get :index, params: {page: User.all.size.to_i / 20, per_page: 20, company_id: User.first.company_id}
        expect(JSON.parse(response.body)['users'].length).to eq 20
        expect(response.body).to include User.last.name
      end

      it 'usersの最後 + 1のページで内容が取得されないこと' do
        users
        get :index, params: {page: User.all.size.to_i / 20 + 1, per_page: 20, company_id: User.first.company_id}
        expect(JSON.parse(response.body)['users'].length).to eq 0
      end
    end

    describe 'POST #create' do
      it '通常ユーザが作成されること' do
        params = {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: 'password',
          password_confirmation: 'password',
          authority: 3,
          company_id: User.first.company_id
        }
        puts params
        post :create, params: params
        # expect(response.body).to include '権限がありません'
        # expect(response.status).to eq 400
      end
    end
  end
end
