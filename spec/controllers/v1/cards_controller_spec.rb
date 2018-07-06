require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::AttendancesController, type: :controller do
  let!(:companies) { create_list(:company, 3) }
  let!(:machine) { create(:machine,company: companies.first) }
  
  it 'API KEYがない場合エラーになること' do
    params = {
      mac_address: machine.mac_address,
      card_id: Faker::Crypto.sha256
    }
    post :create, params: params
    expect(response.body).to include 'APIKEYが違います'
    expect(response.status).to eq 400
  end

  it 'MAC ADDRESSがない場合エラーになること' do
    params = {
      api_key: ENV['APIKEY'],
      card_id: Faker::Crypto.sha256
    }
    post :create, params: params
    expect(response.body).to include 'MAC ADDRESSが違います'
    expect(response.status).to eq 400
  end

  it 'MAC ADDRESSが異なる場合エラーになること' do
    params = {
      api_key: ENV['APIKEY'],
      mac_address: machine.mac_address.reverse,
      card_id: Faker::Crypto.sha256
    }
    post :create, params: params
    expect(response.body).to include 'MAC ADDRESSが違います'
    expect(response.status).to eq 400
  end

  it 'CARD IDがない場合エラーになること' do
    params = {
      api_key: ENV['APIKEY'],
      mac_address: machine.mac_address.reverse
    }
    post :create, params: params
    expect(response.body).to include 'CARD IDは必須です'
    expect(response.status).to eq 400
  end
  
  it '正常にレスポンスを返すこと' do
    params = {
      mac_address: machine.mac_address,
      api_key: ENV['APIKEY'],
      card_id: Faker::Crypto.sha256
    }
    post :create, params: params
    expect(response).to be_successful
  end
end