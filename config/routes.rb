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
    delete 'logout', to: 'sessions#delete'
    resource :users, only: [:create]
    get 'users', to: 'users#index'
    put 'users/update'
    delete 'users/delete'
    
    get 'machines', to: 'machines#index'
    post 'machines/create'
    put 'machines/update'
    delete 'machines/delete'
    
    post 'attendances/create'
    post 'attendances/create_by_site'
    put 'attendances/update'
    delete 'attendances/delete'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
