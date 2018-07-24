# frozen_string_literal: true

require 'faker'
require 'rails_helper'

RSpec.describe V1::SessionsController, type: :controller do
  let!(:company) { create(:company) }
  describe 'ログイン' do
    context '登録ずみのユーザ' do
      let(:user) { create(:user, company_id: company.id) }
      it 'ログインができること' do
        params = {
          email: user.email,
          password: user.password
        }
        post :create, params: params
        expect(response).to be_successful
        expect(response.body).to include user.id.to_s
      end
      it 'emailが異なる場合ログインできないこと' do
        params = {
          email: user.email.reverse,
          password: user.password
        }
        post :create, params: params

        expect(response.status).to eq 401
        expect(response.body).not_to include user.id.to_s
      end
      it 'パスワードが異なる場合ログインできないこと' do
        params = {
          email: user.email,
          password: user.password.reverse
        }
        post :create, params: params

        expect(response.status).to eq 401
        expect(response.body).not_to include user.id.to_s
      end
      it 'emailが空ならログインできないこと' do
        params = {
          email: nil,
          password: user.password
        }
        post :create, params: params

        expect(response.status).to eq 401
        expect(response.body).not_to include user.id.to_s
      end
      it 'パスワードが空ならログインできないこと' do
        params = {
          email: user.email,
          password: nil
        }
        post :create, params: params

        expect(response.status).to eq 401
        expect(response.body).not_to include user.id.to_s
      end
    end
  end

  describe 'ログアウト' do
    context 'ログイン済ユーザ' do
      before do
        create(:user, :admin, company_id: company.id)
        request.headers['Authorization'] = User.first.access_token
      end
      it 'ログアウトできること' do
        delete :delete
        expect(response).to be_successful
        expect(User.first.access_token).to eq nil
      end
    end
  end
end
