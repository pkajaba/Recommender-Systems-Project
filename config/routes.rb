Rails.application.routes.draw do
  resources :jokes
  resources :categories
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  root 'jokes#index'

  get 'recommend_joke' => 'jokes#recommend', as: 'recommend_joke'

  get 'another_create' => 'sessions#anothter_create'

end
