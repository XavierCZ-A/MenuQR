Rails.application.routes.draw do
  constraints(MenuSubdomain) do
    get "/", to: "restaurants#show", as: :restaurant_menu
  end

  direct :public_menu do |restaurant|
    restaurant_menu_url(host: "#{restaurant.slug}.#{Rails.configuration.x.app_host}")
  end

  constraints(MainDomain) do
    resource :session, only: [ :new, :create, :destroy ], path: "login", path_names: { new: "/" }
    resources :users, only: [ :new, :create ], path: "register", path_names: { new: "/" }

    resources :passwords, param: :token

    namespace :admin, path: "dashboard" do
      root "dashboard#show"

      resource :restaurant, only: %i[ edit update ], path: "settings", path_names: { edit: "/" }
      resource :qr_code, only: :show, path: "qr"

      resources :categories, only: %i[ index create update destroy ] do
        patch :order, on: :collection, action: :update_order
      end

      resources :items, except: %i[ index show ] do
        resource :availability, only: %i[ create destroy ], module: :items
      end
    end

    root "admin/dashboard#show"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
