Rails.application.routes.draw do
  resources :main, only: [:index]

  root to: "main#index"
end
