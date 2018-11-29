Rails.application.routes.draw do
  get '/login' => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  get '/auth/:provider/callback' => 'sessions#create', constraints: { provider: /facebook|twitter/ }

  root 'welcome#index'
end
