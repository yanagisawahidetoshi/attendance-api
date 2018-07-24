# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe V1::MachinesController, type: :controller do
  let(:companies) { create_list(:company, 2) }
  let!(:tmp_params) do
    {
      api_key: ENV['APIKEY'],
      company_id: companies.first.id,
      mac_address: Faker::Internet.mac_address
    }
  end
  describe 'POST #create' do
    context 'APIKEYがない場合' do
      it '400を返すこと' do
        tmp_params[:api_key] = nil
        post :create, params: tmp_params

        expect(response.body).to include 'APIKEYが違います'
        expect(response.status).to eq 400
        expect { post(:create) }.to change { Machine.count }.by(0)
      end
    end
    context 'APIKEYが間違っている場合' do
      it '400を返すこと' do
        params = { api_key: ENV['APIKEY'].reverse, company_id: companies.first.id, mac_address: Faker::Internet.mac_address }
        post :create, params: params

        expect(response.body).to include 'APIKEYが違います'
        expect(response.status).to eq 400
        expect { post(:create) }.to change { Machine.count }.by(0)
      end
    end
    context 'COMPANY IDがない場合' do
      it '400を返すこと' do
        tmp_params[:company_id] = nil
        post :create, params: tmp_params

        expect(response.body).to include 'Companyを入力してください'
        expect(response.status).to eq 400
        expect { post(:create) }.to change { Machine.count }.by(0)
      end
    end
    context 'MAC ADDRESSがない場合' do
      it '400を返すこと' do
        tmp_params[:mac_address] = nil
        post :create, params: tmp_params

        expect(response.body).to include 'Mac addressを入力してください'
        expect(response.status).to eq 400
        expect { post(:create) }.to change { Machine.count }.by(0)
      end
    end
    context 'パラメータが正常な場合' do
      it '登録ができること' do
        post :create, params: tmp_params

        expect(response).to be_successful
        expect(Machine.find_by(mac_address: tmp_params[:mac_address]).present?).to eq true
      end
    end
  end
end
