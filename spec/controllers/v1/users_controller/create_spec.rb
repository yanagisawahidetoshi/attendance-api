# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe V1::UsersController, type: :controller do
  let(:company) { build(:company) }
  let(:tmp_params) do
    {
      name: Faker::Name.name,
      email: Faker::Internet.email,
      password: 'password',
      company_id: User.first.company_id
    }
  end

  subject do
    post :create, params: params
    response
  end

  context 'normalUser' do
    before do
      create(:user, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end

    describe 'POST #create' do
      it '通常ユーザの場合ユーザが作成されないこと' do
        post :create
        expect(response.body).to include '権限がありません'
        expect(response.status).to eq 400
        expect { post(:create) }.to change { User.count }.by(0)
      end
    end
  end

  context 'companyAdmin' do
    before do
      create(:user, :companyAdmin, company_id: company.id)
      request.headers['Authorization'] = User.first.access_token
    end

    context '通常ユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['normal']) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    context 'パスワードがなくてもユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['normal'], password: nil) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    context '会社管理ユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['company_admin']) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    context '管理ユーザが作成されないこと' do
      let(:params) { tmp_params.merge(authority: User.authorities['admin']) }
      it { expect(subject.status).to eq 400 }
      it { expect(subject.body).to include 'この権限のユーザを作成する権限がありません' }
      it { expect { subject }.to change { User.count }.by(0) }
    end
  end

  context 'admin' do
    before do
      create(:user, :admin)
      request.headers['Authorization'] = User.first.access_token
    end

    context '通常ユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['normal']) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    context '会社管理ユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['company_admin']) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end

    context '管理ユーザが作成されること' do
      let(:params) { tmp_params.merge(authority: User.authorities['admin']) }
      it { expect(subject).to be_successful }
      it { expect(subject.body).to include params[:email] }
    end
  end
end
