# frozen_string_literal: true

module V1
  class MachinesController < ApplicationController
    skip_before_action :authenticate_user_from_token!, only: [:create]
    before_action :check_auth, only: [:index, :update, :delete]
    before_action :valid_id, only: [:update, :delete]
    
    def index
      machines = Machine
      if strong_params[:company_id]
        machines = machines.where(company_id: strong_params[:company_id])
      end
      machines = machines.page(params[:page]).per(params[:per_page])
      render json: {machines: machines, total: machines.total_pages}
    end
    
    def create
      if strong_params_for_create[:api_key].blank?
        render status: 400, json: { message: 'APIKEYを入力してください' } and return
      end
      unless strong_params_for_create[:api_key] == ENV["APIKEY"]
        render status: 400, json: { message: 'APIKEYが違います' } and return
      end
      machine = Machine.create(strong_params)
      unless machine.valid?
        render status: 400, json: { message: machine.errors.full_messages } and return
      end
      
    end
    
    private
    
    def strong_params
      params.permit(:id, :name, :company_id, :mac_address)
    end
    
    def strong_params_for_create
      params.permit(:api_key, :mac_address, :company_id)
    end
    
    def check_auth
      if current_user[:authority] == User.authorities["normal"]
        render status: 400, json: { message: '権限がありません' } and return
      end
      
      if current_user[:authority] != User.authorities["admin"] && 
        strong_params[:company_id].nil?
          render status: 400, json: { message: '会社IDは必須です' } and return
      end
      
      if current_user[:authority] == User.authorities["company_admin"] &&
        strong_params[:company_id].to_i != current_user[:company_id].to_i
          render status: 400, json: { message: '会社IDが間違っています' } and return
      end
    end
  end
end