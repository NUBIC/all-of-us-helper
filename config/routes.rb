Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :invitation_codes,  only: [:index, :show]
  resources :patients,  only: [:index, :show]
  resources :users, only: :show

  root 'home#index'
end
