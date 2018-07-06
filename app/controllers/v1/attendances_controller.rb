# frozen_string_literal: true

module V1
  class AttendancesController < ApplicationController
    skip_before_action :authenticate_user_from_token!
    before_action :valid_id

    def create
      add_card && return if Card.find_by(card_id: params[:card_id]).blank?
      
    end

    private

    def card_params
      params.permit(:card_id)
    end

    def add_card
      token = Digest::MD5.hexdigest(SecureRandom.hex)
      card = Card.new(
        card_id: card_params[:card_id],
        company: Company.find(machine.company_id),
        token: token
      )
      render json: { card: card }
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
  end
end
