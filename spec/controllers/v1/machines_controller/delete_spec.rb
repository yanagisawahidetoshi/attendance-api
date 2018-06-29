require 'faker'
require 'rails_helper'
Faker::Config.locale = :ja

RSpec.describe V1::MachinesController, type: :controller do
  let(:companies) { create_list(:company, 2) }
  let!(:machines1) { create(:machine, company: companies.first) }

  describe '#delete' do
    context 'adminユーザ' do
      before do
        create(:user, :admin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      
      it '削除できること' do
        params = {id: machines1.id}
        delete :delete, params: params
        
        expect(response).to be_successful
        expect(Machine.find_by_id(params[:id])).to eq nil
      end
    end
    context 'company adminユーザ' do
      before do
        create(:user, :companyAdmin, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      
      it '削除できないこと' do
        params = {id: machines1.id}
        delete :delete, params: params
        
        expect(response.status).to eq 400
        expect { delete(:delete) }.to change { Machine.count }.by(0)
      end
    end
    context 'normalユーザ' do
      before do
        create(:user, company_id: companies.first.id)
        request.headers['Authorization'] = User.first.access_token
      end
      
      it '削除できないこと' do
        params = {id: machines1.id}
        delete :delete, params: params
        
        expect(response.status).to eq 400
        expect { delete(:delete) }.to change { Machine.count }.by(0)
      end
    end
  end
end