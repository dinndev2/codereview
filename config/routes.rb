Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Redirect favicon.ico to icon.png (browsers automatically request favicon.ico)
  get "favicon.ico", to: redirect("/icon.png", status: 301)

  # Defines the root path route ("/")
  # root "posts#index"
  resources :pull_requests, only: [:index, :show, :create]
  root "pull_requests#index"
end
