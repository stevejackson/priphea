Rails.application.routes.draw do
  resources :settings, only: [:index] do
    collection do
      post 'save'
    end
  end

  resources :main, only: [:index]

  root to: "main#index"
end
