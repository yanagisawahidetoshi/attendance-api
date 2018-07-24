# frozen_string_literal: true

require 'faker'
require 'rails_helper'

RSpec.describe V1::AttendancesController, type: :controller do
  let!(:companies) { create_list(:company, 3) }
  let!(:machine) { create(:machine, company: companies.first) }
  let!(:card) { create(:card, company_id: companies.first.id) }
  context '標準ユーザ' do
    before do
      create(:user, company_id: companies.first.id, card_id: card.id)
      request.headers['Authorization'] = User.first.access_token
    end
    context '自分自身を' do
      describe '登録' do
        it 'recessとoperating_timeがそのまま登録されること' do
          params = {
            in_time: '09:50',
            out_time: '19:03',
            date: '2018-07-15',
            recess: 2,
            operating_time: 9,
            rest: 1
          }
          post :create_by_site, params: params

          expect(Attendance.first.recess).to eq params[:recess]
          expect(Attendance.first.operating_time).to eq params[:operating_time]
          expect(Attendance.first.rest).to eq params[:rest]
        end
        it 'recessとoperating_timeが追加されること' do
          params = {
            in_time: '09:50',
            out_time: '19:03',
            date: '2018-07-15'
          }
          post :create_by_site, params: params
          expect(Attendance.first.recess).not_to eq nil
          expect(Attendance.first.operating_time).not_to eq nil
        end
        it 'recessとoperating_timeが追加されないこと' do
          params = {
            in_time: '09:50',
            date: '2018-07-15'
          }
          post :create_by_site, params: params
          expect(Attendance.first.recess).to eq nil
          expect(Attendance.first.operating_time).to eq nil
        end
        it '日付と休み区分が登録されること' do
          params = {
            date: '2018-07-15',
            rest: 1
          }
          post :create_by_site, params: params
          expect(Attendance.first.rest).to eq params[:rest]
          expect(Attendance.first.operating_time).to eq nil
          expect(Attendance.first.recess).to eq nil
        end
      end
      describe '更新' do
        let!(:attendance) { create(:attendance, user: User.first) }

        it '更新されること' do
          param = {
            id: attendance.id,
            date: attendance.date + 1,
            in_time: attendance.in_time + (60 * 60),
            recess: 1,
            operating_time: 9
          }
          put :update, params: param
          expect(Attendance.first[:operating_time]).to eq param[:operating_time]
          expect(Attendance.first[:recess]).to eq param[:recess]
        end
        it '休憩時間と総稼働時間がない場合計算して求められること' do
          param = {
            id: attendance.id,
            date: attendance.date + 1,
            in_time: attendance.in_time + (60 * 60)
          }
          put :update, params: param
          expect(Attendance.first[:operating_time]).not_to eq attendance[:operating_time]
          expect(Attendance.first[:recess]).not_to eq attendance[:recess]
        end
        it '出退勤が入力済みなら計算して求めれれること' do
          param = {
            id: attendance.id,
            date: attendance.date + 1
          }
          put :update, params: param
          expect(Attendance.first[:operating_time]).not_to eq attendance[:operating_time]
          expect(Attendance.first[:recess]).not_to eq attendance[:recess]
        end
        it '休憩、稼働時間が0を渡せばそれが反映さえること' do
          param = {
            id: attendance.id,
            date: attendance.date + 1,
            in_time: attendance.in_time + (60 * 60),
            recess: 0,
            operating_time: 0
          }
          put :update, params: param
          expect(Attendance.first[:operating_time]).to eq 0
          expect(Attendance.first[:recess]).to eq 0
        end
      end
      describe '削除' do
        let!(:attendance) { create(:attendance, user: User.first) }

        it '削除できること' do
          delete :delete, params: { id: attendance.id }
          expect(Attendance.find_by(id: attendance.id)).to eq nil
        end
      end
    end
    context '他の人を' do
      let!(:card2) { create(:card, company_id: companies.first.id) }
      let!(:user2) { create(:user, company_id: companies.first.id, card_id: card2.id) }
      it '登録できないこと' do
        params = {
          in_time: '09:50',
          out_time: '19:03',
          date: '2018-07-15',
          user_id: user2.id
        }
        post :create_by_site, params: params
        expect(response.body).to include '権限がありません'
      end
      it '更新できないこと' do
        attendance2 = create(:attendance, user: user2)
        param = {
          id: attendance2.id,
          date: attendance2.date + 1,
          user_id: user2.id
        }
        put :update, params: param
        expect(response.body).to include '権限がありません'
      end
      it '削除できないこと' do
        attendance2 = create(:attendance, user: user2)
        delete :delete, params: { id: attendance2.id, user_id: user2.id }
        expect(response.body).to include '権限がありません'
        expect(Attendance.find_by(id: attendance2.id)).not_to eq nil
      end
    end
  end

  context 'company admin' do
    before do
      create(:user, :companyAdmin, company_id: companies.first.id, card_id: card.id)
      request.headers['Authorization'] = User.first.access_token
    end
    context '自分自身を' do
      it '登録できること' do
        params = {
          in_time: '09:50',
          out_time: '19:03',
          date: '2018-07-15',
          recess: 2,
          operating_time: 9,
          rest: 1
        }
        post :create_by_site, params: params

        expect(Attendance.first.recess).to eq params[:recess]
        expect(Attendance.first.operating_time).to eq params[:operating_time]
        expect(Attendance.first.rest).to eq params[:rest]
      end
      it '更新できること' do
        attendance = create(:attendance, user: User.first)
        param = {
          id: attendance.id,
          date: attendance.date + 1,
          in_time: attendance.in_time + (60 * 60),
          recess: 1,
          operating_time: 9
        }
        put :update, params: param
        expect(Attendance.first[:operating_time]).to eq param[:operating_time]
        expect(Attendance.first[:recess]).to eq param[:recess]
      end
      it '削除できること' do
        attendance = create(:attendance, user: User.first)
        delete :delete, params: { id: attendance.id }
        expect(Attendance.find_by(id: attendance.id)).to eq nil
      end
    end
    context '同一会社の他人を' do
      let!(:card2) { create(:card, company_id: companies.first.id) }
      let!(:user2) { create(:user, company_id: companies.first.id, card_id: card2.id) }
      it '登録できること' do
        params = {
          in_time: '09:50',
          out_time: '19:03',
          date: '2018-07-15',
          recess: 2,
          operating_time: 9,
          rest: 1,
          user_id: user2.id
        }
        post :create_by_site, params: params

        expect(Attendance.first.recess).to eq params[:recess]
        expect(Attendance.first.operating_time).to eq params[:operating_time]
        expect(Attendance.first.rest).to eq params[:rest]
      end
      it '存在しないユーザは登録できないこと' do
        params = {
          in_time: '09:50',
          out_time: '19:03',
          date: '2018-07-15',
          user_id: user2.id.to_i + 1
        }
        expect { post :create_by_site, params: params }.to change { Attendance.count }.by(0)
        expect(response.body).to include 'ユーザが見つかりません'
      end
      it '更新できること' do
        attendance = create(:attendance, user: user2)
        param = {
          id: attendance.id,
          date: attendance.date + 1,
          in_time: attendance.in_time + (60 * 60),
          recess: 1,
          operating_time: 9
        }
        put :update, params: param
        expect(Attendance.first[:operating_time]).to eq param[:operating_time]
        expect(Attendance.first[:recess]).to eq param[:recess]
      end
      it '削除できること' do
        attendance = create(:attendance, user: user2)
        delete :delete, params: { id: attendance.id }
        expect(Attendance.find_by(id: attendance.id)).to eq nil
      end
    end
    context '別会社のユーザを' do
      let!(:other_company_user) { create(:user, company_id: companies.second.id) }
      it '登録できないこと' do
        params = {
          in_time: '09:50',
          out_time: '19:03',
          date: '2018-07-15',
          user_id: other_company_user.id
        }
        post :create_by_site, params: params

        expect { post :create_by_site, params: params }.to change { Attendance.count }.by(0)
        expect(response.body).to include '権限がありません'
      end
      it '更新できないこと' do
        attendance = create(:attendance, user: other_company_user)
        param = {
          id: attendance.id,
          date: attendance.date + 1,
          in_time: attendance.in_time + (60 * 60),
          recess: 1,
          operating_time: 9
        }
        put :update, params: param
        expect(response.body).to include '権限がありません'
      end
      it '削除できないこと' do
        attendance = create(:attendance, user: other_company_user)

        expect { delete :delete, params: { id: attendance.id } }.to change { Attendance.count }.by(0)
        expect(response.body).to include '権限がありません'
      end
    end
  end
end
