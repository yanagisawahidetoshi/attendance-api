# frozen_string_literal: true

require 'faker'
require 'rails_helper'

RSpec.describe V1::AttendancesController, type: :controller do
  let!(:companies) { create_list(:company, 3) }
  let!(:machine) { create(:machine, company: companies.first) }
  let!(:card) { create(:card, company_id: companies.first.id) }
  before do
    create(:user, :admin, company_id: companies.first.id, card_id: card.id)
    request.headers['Authorization'] = User.first.access_token
  end
  it '時刻がない場合エラーになること' do
    params = {
      mac_address: machine.mac_address,
      api_key: ENV['APIKEY'],
      card_id: card.card_id
    }

    post :create, params: params
    expect(response.body).to include '時刻は必須です'
    expect(response.status).to eq 400
  end

  it 'in_timeに値が格納されること' do
    params = {
      mac_address: machine.mac_address,
      api_key: ENV['APIKEY'],
      card_id: card.card_id,
      time: Time.now.to_i
    }
    post :create, params: params

    expect(Attendance.first.in_time).not_to eq nil
    expect(Attendance.first.out_time).to eq nil
  end

  it 'out_timeに値が格納されること' do
    attendance = create(:attendance, out_time: nil, user: User.first)
    params = {
      mac_address: machine.mac_address,
      api_key: ENV['APIKEY'],
      card_id: card.card_id,
      time: Time.zone.parse("#{attendance.date} 19:10:00").to_i
    }
    post :create, params: params
    expect(Attendance.first.in_time).not_to eq nil
    expect(Attendance.first.out_time).not_to eq nil
    expect(Attendance.first.recess).not_to eq nil
    expect(Attendance.first.operating_time).not_to eq nil
  end
end
