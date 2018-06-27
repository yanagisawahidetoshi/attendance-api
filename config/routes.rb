Rails.application.routes.draw do
  namespace :v1 do
    get 'companies', to: 'companies#index'
    post 'companies/create'
    put 'companies/update'
    delete 'companies/delete'
  end
  devise_for :users, only: []

  namespace :v1, defaults: { format: :json } do
    resource :login, only: [:create], controller: :sessions
    resource :users, only: [:create]
    get 'users', to: 'users#index'
    put 'users/update'
    delete 'users/delete'
    
    get 'machines', to: 'machines#index'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
