Rails.application.routes.draw do
  resources :codes

  root to: 'visitors#index'
  devise_for :users
  resources :users
  get 'qrgen', to: 'codes#qrgen'
  get 'qrscan', to: 'codes#qrscan'
  get 'qrpage', to: 'codes#qrpage'
  post 'qrscanner', to: 'codes#qrscanner'
  post 'pdfscanner', to: 'codes#pdfscanner'
end
