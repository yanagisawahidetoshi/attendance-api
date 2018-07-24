class ApplicationController < ActionController::API
  include AbstractController::Translation

  before_action :authenticate_user_from_token!

  respond_to :json

  ##
  # User Authentication
  # Authenticates the user with OAuth2 Resource Owner Password Credentials
  def authenticate_user_from_token!
    auth_token = request.headers['Authorization']

    if auth_token
      authenticate_with_auth_token auth_token
    else
      authenticate_error
    end
  end
  
  protected
  
  def is_admin
    current_user[:authority] == User.authorities['admin']
  end
  
  def is_company_admin_user
    current_user[:authority] == User.authorities['company_admin']
  end
  
  def is_normal_user
    current_user[:authority] == User.authorities['normal']
  end
  
  def render_bad_request(message)
    render(status: :bad_request, json: { message: message })
  end

  def is_build_difference_company
    !is_admin && is_difference_company
  end

  def is_difference_company
    current_user[:company_id].to_i != params[:company_id].to_i
  end
  
  def check_params_authority(user_auth)
    params[:authority].to_i == User.authorities[user_auth].to_i
  end

  def check_api_key
    if params[:api_key].blank? || params[:api_key] != ENV['APIKEY']
      false
    else
      true
    end
  end
  
  def different_user_id_for_param
    current_user[:id].to_i != params[:id].to_i
  end

  private

  def authenticate_with_auth_token auth_token
    unless auth_token.include?(':')
      authenticate_error
      return
    end

    user_id = auth_token.split(':').first
    user = User.where(id: user_id).first

    if user && Devise.secure_compare(user.access_token, auth_token)
      # User can access
      sign_in user, store: false
    else
      authenticate_error
    end
  end

  ##
  # Authentication Failure
  # Renders a 401 error
  def authenticate_error
    render json: { error: t('devise.failure.unauthenticated') }, status: 401
  end
end
