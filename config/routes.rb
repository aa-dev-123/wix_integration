Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/auth/wix', to: 'oauth#wix_auth'
  get '/oauth/callback', to: 'oauth#wix_callback'
  get 'oauth/authorize', to: 'oauth#authorize'

  resources :overviews

  root 'overviews#index'
end
