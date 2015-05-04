Rails.application.routes.draw do

  namespace :api do
    resources :albums, only: [:index, :show]
    resources :songs, only: [:show, :update]
    resources :song_files, only: [:show]
  end

  resources :settings, only: [:index] do
    collection do
      post 'save'
    end
  end

  get '/cover_art/:album_id' => 'cover_art#cover_art_cache', as: :cover_art

  resources :main, only: [:index] do
    collection do
      get 'rescan'
      get 'destroy_and_rescan'
    end
  end

  get '/rescan' => 'main#rescan', as: :rescan
  get '/destroy_and_rescan' => 'main#destroy_and_rescan', as: :destroy_and_rescan

  root to: "main#index"
end
