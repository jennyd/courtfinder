Courtfinder::Application.routes.draw do

  # Public court pages
  # TODO: This needs tidying
  scope 'courts', :controller => :courts do
    match '/' => :index, :as => :courts
    match '/:id' => :show, :as => :court
  end

  # Admin section
  get 'admin', to: redirect('/admin/courts')

  devise_for :users, path_prefix: 'admin'

  namespace :admin do
    resources :users
    resources :addresses
    resources :towns
    resources :counties
    resources :countries
    resources :address_types, path: '/address-types'

    resources :courts do
      collection do
        get :areas_of_law
        get :court_types
        get :postcodes
        get :family
        get :audit
      end
    end

    resources :councils do
      collection do
        get :complete
      end
    end

    resources :court_types

    resources :areas_of_law, path: '/areas-of-law'

    resources :area_of_law_groups, path: '/area-of-law-groups'

    resources :opening_types

    resources :contact_types

    resources :facilities

    resources :regions

    resources :areas
  end

  get '/api' => 'home#api'

  root :to => redirect('/admin/courts')

  resource :feedback
end
