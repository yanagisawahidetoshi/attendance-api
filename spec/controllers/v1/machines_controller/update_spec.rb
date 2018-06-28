require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::MachinesController, type: :controller do
  let!(:companies) { create_list(:company, 3) }
  describe '#update' do
    context 'adminユーザ' do
      before do
        create(:user, :admin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      
      let!(:machines1) { create(:machine, company: companies.first) }
      let!(:machines2) { create(:machine, company: companies.second) }
      let!(:machines3) { create(:machine, company: companies.third) }
      it 'companyを変更できること' do
        params = { id: machines1.id, company_id: companies.second.id }
        put :update, params: params
        
        expect(response).to be_successful
        expect(response.body).to include params[:company_id].to_s
      end
      it 'nameを変更できること' do
        params = { id: machines1.id, name: Faker::Name.name }
        put :update, params: params
        
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end
      it 'mac addressは変更できないこと' do
        params = { id: machines1.id, mac_address: Faker::Internet.mac_address }
        put :update, params: params
        
        expect(response).to be_successful
        expect(Machine.find_by(mac_address: params[:mac_address]).nil?).to eq true
      end
    end
    
    context 'company adminユーザ' do
      before do
        create(:user, :companyAdmin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      let!(:machines1) { create(:machine, company: companies.first) }
      let!(:machines2) { create(:machine, company: companies.second) }
      let!(:machines3) { create(:machine, company: companies.third) }
      
      it 'companyは変更できないことと' do
        params = { id: machines1.id, company_id: companies.second.id }
        put :update, params: params
        
        expect(response.status).to eq 400
        expect(Machine.find(params[:id]).company_id).not_to eq params[:company_id]
      end
      it 'nameを変更できること' do
        params = { id: machines1.id, name: Faker::Name.name, company_id: User.first.company_id }
        put :update, params: params
        
        expect(response).to be_successful
        expect(response.body).to include params[:name]
      end
      it 'mac addressは変更できないこと' do
        params = { id: machines1.id, mac_address: Faker::Internet.mac_address, company_id: User.first.company_id }
        put :update, params: params
        
        expect(response).to be_successful
        expect(Machine.find_by(mac_address: params[:mac_address]).nil?).to eq true
      end
    end
    
    context 'normal ユーザ' do
      before do
        create(:user, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      let!(:machines1) { create(:machine, company: companies.first) }
      it '更新できないこと' do
        params = { id: machines1.id, name: Faker::Name.name, company_id: User.first.company_id }
        put :update, params: params
        
        expect(response.status).to eq 400
        expect(response.body).to include '権限がありません'
        
      end
    end
  end
end