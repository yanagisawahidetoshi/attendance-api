# frozen_string_literal: true

module V1
  class MachinesController < ApplicationController
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
    
    private
    
    def strong_params
      params.permit(:id, :name, :company_id, :mac_address)
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