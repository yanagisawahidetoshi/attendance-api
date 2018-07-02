# frozen_string_literal: true

module V1
  class MachinesController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :check_auth, only: %i[index update delete]
    before_action :valid_id, only: %i[update delete]

    def index
      machines = Machine
      if strong_params[:company_id]
        machines = machines.where(company_id: strong_params[:company_id])
      end
      machines = machines.page(params[:page]).per(params[:per_page])
      render json: { machines: machines, total: machines.total_pages }
    end

    def create
      unless check_api_key
        render(status: :bad_request, json: { message: 'APIKEYが違います' }) && return
      end
      machine = Machine.create(strong_params)
      unless machine.valid?
        render(status: :bad_request, json: { message: machine.errors.full_messages }) && return
      end
    end

    def update
      if current_user[:authority] == User.authorities['company_admin']
        strong_params_for_update.delete(:company_id)
      end

      @machine.update(strong_params_for_update)
      render json: { machine: @machine }
    end

    def delete
      @machine.destroy
    end

    private

    def strong_params
      params.permit(:id, :name, :company_id, :mac_address)
    end

    def strong_params_for_create
      params.permit(:api_key, :mac_address, :company_id)
    end

    def strong_params_for_update
      params.permit(:id, :name, :company_id)
    end

    def check_auth
      if current_user[:authority] == User.authorities['normal']
        render(status: :bad_request, json: { message: '権限がありません' }) && return
      end

      if current_user[:authority] != User.authorities['admin'] &&
         strong_params[:company_id].nil?
        render(status: :bad_request, json: { message: '会社IDは必須です' }) && return
      end

      if current_user[:authority] == User.authorities['company_admin'] &&
         strong_params[:company_id].to_i != current_user[:company_id].to_i
        render(status: :bad_request, json: { message: '会社IDが間違っています' }) && return
      end
    end

    def valid_id
      @machine = Machine.find_by(id: strong_params_for_update[:id])
    end
  end
end
