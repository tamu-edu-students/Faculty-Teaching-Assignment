# frozen_string_literal: true

Rails.application.routes.draw do
  resources :schedules
  get 'sessions/logout'
  get 'sessions/omniauth'
  get 'users/show'
  get 'welcome/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  get 'welcome/index', to: 'welcome#index', as: 'welcome'
  root 'welcome#index'

  # Login/logout
  get '/logout', to: 'sessions#logout', as: 'logout'
  get '/auth/google_oauth2/callback', to: 'sessions#omniauth'

  # Upload CSV
  post 'upload_csv', to: 'csv#upload'

  resources :schedules do
    resources :rooms, only: [:index]
    post :upload_rooms, on: :member

    resources :instructors, only: [:index]
    post :upload_instructors, on: :member

    resources :courses, only: [:index]
    post :upload_courses, on: :member

    post 'time_slots', to: 'time_slots#filter', as: 'filter_time_slots'

    get '/time_slots', to: 'time_slots#index'
    post '/courses/fetch_courses', to: 'courses#fetch_courses'

    resources :room_bookings, only: [:index]
  end

  # Show Time Slot View
  resources :time_slots, only: [:index]
end
