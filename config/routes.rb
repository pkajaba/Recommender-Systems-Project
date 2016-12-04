Rails.application.routes.draw do
  resources :jokes, only: :index
  resources :categories, only: :index
  resources :users, only: [:new, :create]
  resources :ratings, only: :update
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  root 'users#about'

  get 'recommend_joke' => 'jokes#recommend', as: 'recommend_joke'

  get 'profile' => 'users#show', as: 'profile'
  get 'about' => 'users#about', as: 'about'

  get 'login' => 'sessions#login', as: 'login'


end
