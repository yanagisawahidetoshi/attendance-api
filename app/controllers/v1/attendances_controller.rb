# frozen_string_literal: true

module V1
  class AttendancesController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: :create
    before_action :valid_id, only: :create
    before_action :valid_id_by_site, only: %i[update delete]
    before_action :check_auth, only: %i[create_by_site update delete]

    def create
      add_card && return if card.blank?
      if params[:time].blank?
        render(status: :bad_request, json: { message: '時刻は必須です' }) && return
      end
      attendance = Attendance.search_date(date, user).first
      if attendance.blank?
        create_attendance && return
      else
        update_attendance(attendance) && return
      end
    end

    def create_by_site
      attendance = Attendance.new(create_by_site_params)

      attendance.user = if params[:user_id].blank?
                          current_user
                        else
                          User.find_by(id: params[:user_id])
                        end

      render_bad_request('ユーザが見つかりません') && return if attendance.user.nil?

      if attendance.recess.nil?
        attendance.recess = attendance.recess_hour(attendance.in_time, attendance.out_time)
      end
      if attendance.operating_time.nil?
        attendance.operating_time = attendance.build_operating_time(attendance)
      end

      attendance.save
      render json: { attendance: attendance }
    end

    def update
      if params[:recess].nil?
        @attendance.recess = @attendance.recess_hour(@attendance.in_time, @attendance.out_time)
      end
      if params[:operating_time].nil?
        @attendance.operating_time = @attendance.build_operating_time(@attendance)
      end
      @attendance.update(create_by_site_params)
      render json: { attendance: @attendance }
    end

    def delete
      @attendance.destroy
    end

    private

    def card_params
      params.permit(:card_id)
    end

    def create_by_site_params
      params.permit(:date, :in_time, :out_time, :recess, :operating_time, :rest)
    end

    def create_attendance
      attendance = Attendance.new(
        user: user,
        date: date,
        in_time: date_time.strftime('%H:%M')
      )
      attendance.save
      render json: { attendance: attendance } && return
    end

    def update_attendance(attendance)
      attendance.out_time = date_time.strftime('%H:%M')
      attendance.recess = attendance.recess_hour(attendance.in_time, attendance.out_time)
      attendance.operating_time = attendance.build_operating_time(attendance)
      attendance.save
      render json: { attendance: attendance }
    end

    def add_card
      token = Digest::MD5.hexdigest(SecureRandom.hex)
      card = Card.new(
        card_id: card_params[:card_id],
        company: Company.find(machine.company_id),
        token: token
      )
      card.save
      render json: { card: card }
    end

    def date_time
      @date_time ||= Time.zone.at(params[:time].to_i)
    end

    def date
      @date ||= date_time.strftime('%Y-%m-%d')
    end

    def card
      @card ||= Card.find_by(card_id: params[:card_id])
    end

    def user
      @user ||= User.search_card_id(Card.search_card_id(card.card_id)).first
    end

    def machine
      @machine ||= Machine.find_by(mac_address: params[:mac_address])
    end

    def valid_id
      unless check_api_key
        render(status: :bad_request, json: { message: 'APIKEYが違います' }) && return
      end
      if params[:card_id].blank?
        render(status: :bad_request, json: { message: 'CARD IDは必須です' }) && return
      end
      if machine.blank?
        render(status: :bad_request, json: { message: 'MAC ADDRESSが違います' }) && return
      end
    end

    def check_auth
      return if params[:user_id].blank?

      if User.find_by(id: params[:user_id]).blank?
        render_bad_request('ユーザが見つかりません') && return
      end
      if is_normal_user && current_user[:id].to_i != params[:user_id].to_i
        render_bad_request('権限がありません') && return
      end
      if is_company_admin_user && current_user[:company_id].to_i != User.company_id(params[:user_id]).to_i
        render_bad_request('権限がありません') && return
      end
    end

    def valid_id_by_site
      @attendance = Attendance.find_by(id: params[:id])

      if is_company_admin_user && current_user[:company_id].to_i != User.company_id(@attendance.user_id).to_i
        render_bad_request('権限がありません') && return
      end
    end
  end
end
