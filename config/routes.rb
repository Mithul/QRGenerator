Rails.application.routes.draw do
  resources :codes

  root to: 'visitors#index'
  devise_for :users
  resources :users
  get 'qrgen', to: 'codes#qrgen'
  get 'qrpage', to: 'codes#qrpage'
end
