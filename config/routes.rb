Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'registrations' }
  root 'home#show'

  namespace :admin do
    resources :users, only: [:index, :destroy] do
      put :lock
      put :unlock
      put :toggle_admin
      put :toggle_valid
    end
  end

  resources :items do
    get :image
    put :lock
    put :unlock
    put :claim
    put :unclaim
  end
end
