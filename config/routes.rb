Rails.application.routes.draw do

  namespace :api do
    resources :albums, only: [:index, :show]
    resources :songs, only: [:show]
    resources :song_files, only: [:show]
  end


  resources :settings, only: [:index] do
    collection do
      post 'save'
    end
  end

  get '/cover_art/:album_id' => 'cover_art#cover_art_cache', as: :cover_art

  resources :main, only: [:index]

  root to: "main#index"
end
