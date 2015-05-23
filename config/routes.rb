Rails.application.routes.draw do

  namespace :api do
    resources :albums, only: [:index, :show]
    resources :songs, only: [:index, :show, :update]
    resources :song_files, only: [:show]
    resources :smart_playlists, only: [:index, :show]
    resources :player, only: [] do
      collection do
        post 'set_song_queue'
        post 'set_song_queue_and_play'
        get 'pause'
        get 'resume'
        get 'update_and_get_status'
        post 'seek'
        post 'set_volume'
        post 'next_song'
      end
    end
  end

  resources :smart_playlists

  resources :settings, only: [:index] do
    collection do
      post 'save'
    end
  end

  resources :albums do
  end

  get '/cover_art/:album_id' => 'cover_art#cover_art_cache', as: :cover_art

  resources :main, only: [:index] do
    collection do
      post 'rescan'
      post 'destroy_and_rescan'
      post 'update_cover_art_cache'
    end
  end

  post '/rescan' => 'main#rescan', as: :rescan
  post '/destroy_and_rescan' => 'main#destroy_and_rescan', as: :destroy_and_rescan
  post '/update_cover_art_cache' => 'main#update_cover_art_cache', as: :update_cover_art_cache

  root to: "main#index"
end
