# frozen_string_literal: true

require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::MachinesController, type: :controller do
  let!(:companies) { create_list(:company, 3) }
  describe '#index' do
    context 'adminユーザ' do
      before do
        create(:user, :admin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end

      let!(:machines1) { create_list(:machine, 3, company: companies.first) }
      let!(:machines2) { create_list(:machine, 3, company: companies.second) }
      let!(:machines3) { create_list(:machine, 3, company: companies.third) }
      context '会社IDがない場合' do
        it '全てのmachineが取得されること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page }
          body = JSON.parse(response.body)

          expect(body['machines'].length).to eq per_page
          expect(response.body).to include machines1.first.mac_address
          expect(body['total']).to eq 3
        end
      end
      context '会社IDがある場合' do
        it '特定のmachineが取得されること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page, company_id: companies.first.id }
          body = JSON.parse(response.body)

          expect(body['machines'].length).to eq per_page
          expect(response.body).to include machines1.first.mac_address
          expect(body['total']).to eq machines1.size.to_i / per_page
        end
      end
    end

    context 'companyAdmin' do
      before do
        create(:user, :companyAdmin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      context '会社IDがない場合' do
        it 'エラーになること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page }

          expect(response.body).to include '会社IDは必須です'
          expect(response.status).to eq 400
        end
      end
      context '異なる会社IDの場合' do
        it 'エラーになること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page, company_id: companies.second.id }

          expect(response.body).to include '会社IDが間違っています'
          expect(response.status).to eq 400
        end
      end
      context '同一会社IDの場合' do
        let!(:machines1) { create_list(:machine, 3, company: companies.first) }
        let!(:machines2) { create_list(:machine, 3, company: companies.second) }

        it '正常に取得できること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page, company_id: companies.first.id }
          body = JSON.parse(response.body)

          expect(body['machines'].length).to eq per_page
          expect(response.body).to include machines1.first.mac_address
          expect(body['total']).to eq machines1.size.to_i / per_page
        end
      end
    end

    context 'normal user' do
      before do
        create(:user, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      context '会社IDがない場合' do
        it 'エラーになること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page }

          expect(response.body).to include '権限がありません'
          expect(response.status).to eq 400
        end
      end
      context '異なる会社IDの場合' do
        it 'エラーになること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page, company_id: companies.second.id }

          expect(response.body).to include '権限がありません'
          expect(response.status).to eq 400
        end
      end
      context '同一会社IDの場合' do
        it 'エラーになること' do
          per_page = 3
          get :index, params: { page: 1, per_page: per_page, company_id: companies.first.id }

          expect(response.body).to include '権限がありません'
          expect(response.status).to eq 400
        end
      end
    end
  end
end
