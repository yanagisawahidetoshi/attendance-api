require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do
  context 'normalUser' do
    before do
      create(:user, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }

    describe 'POST #create' do
      it '通常ユーザの場合ユーザが作成されないこと' do
        post :create
        expect(response.body).to include '権限がありません'
        expect(response.status).to eq 400
      end
    end
  end
  
  context 'companyAdmin' do
    before do
      create(:user, :companyAdmin, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end

    subject do
      post :create, params: params
      response
    end
    let(:users) { create_list(:user, 99, company_id: company.id) }
    let(:company) { create(:company) }

    context '通常ユーザが作成されること' do
      let(:params) {{
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password',
        authority: 3,
        company_id: User.first.company_id
      }}
      
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    it '会社管理ユーザが作成されること' do
      params = {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password',
        authority: 2,
        company_id: User.first.company_id
      }
      post :create, params: params
      expect(response).to be_successful
      expect(response.body).to include params[:email]
    end
    it '管理ユーザが作成されないこと' do
      params = {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password',
        authority: 1,
        company_id: User.first.company_id
      }
      post :create, params: params
      expect(response.status).to eq 400
      expect(response.body).to include 'この権限のユーザを作成する権限がありません'
    end
  end
end
