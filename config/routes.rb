Rails.application.routes.draw do

  namespace :api do
    resources :albums, only: [:index, :show] do
      member do
        post 'change_album_art'
      end
    end
    resources :songs, only: [:show, :update] do
      collection do
        get :playback_queue
      end
    end
    resources :settings, only: [] do
      collection do
        post 'rescan'
        post 'restart_priphea_backend'
      end
    end
    resources :song_files, only: [:show]
    resources :smart_playlists, only: [:index, :show]
    resources :player, only: [] do
      collection do
        post 'set_song_queue'
        post 'set_song_queue_and_play'
        post 'pause'
        post 'resume'
        get 'update_and_get_status'
        post 'seek'
        post 'set_volume'
        post 'next_song'
      end
    end
  end

  resources :smart_playlists

  resources :albums do
    member do
      post 'delete_all_songs_from_database'
      post 'delete_all_songs_from_database_with_files'
      patch 'update_all_songs_metadata'
      post :deep_rescan_specific_directory
    end
  end

  get '/cover_art/:album_id' => 'cover_art#cover_art_cache', as: :cover_art

  resources :main, only: [:index] do
    collection do
      post 'destroy_and_rescan'
      post 'update_cover_art_cache'
      post 'check_file_existence'
      post 'delete_missing_unrated_files'
    end
  end

  post '/destroy_and_rescan' => 'main#destroy_and_rescan', as: :destroy_and_rescan
  post '/update_cover_art_cache' => 'main#update_cover_art_cache', as: :update_cover_art_cache
  post '/check_file_existence' => 'main#check_file_existence', as: :check_file_existence
  post '/delete_missing_unrated_files' => 'main#delete_missing_unrated_files', as: :delete_missing_unrated_files

  root to: "main#index"
end
