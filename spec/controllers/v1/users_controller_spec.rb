require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do
  context '権限のないユーザ' do
    before do
      create(:user, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end
    let(:company) { create(:company) }
    
    describe 'GET #index' do
      it '権限エラーになること' do
        get :index
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
    let(:company) { create(:company) }
    
    describe 'GET #index' do
      it '異なるcompany_idなら権限エラーになること' do
        get :index, params: {company_id: company.id.to_i + 1}
        expect(response.body).to include '権限がありません'
        expect(response.status).to eq 400
      end
    end
  end
end
