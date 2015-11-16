Rails.application.routes.draw do
  resources :api_keys

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get 'data_distributions/new' => 'data_distributions#new'
  post 'data_distributions' => 'data_distributions#create'
  get ':username/data_distributions' => 'data_distributions#index'
  get ':username/data_distributions/:id' => 'data_distributions#show'
  delete ':username/data_distributions/:id' => 'data_distributions#destroy'
  put ':username/data_distributions/:id' => 'data_distributions#update'
  patch ':username/data_distributions/:id' => 'data_distributions#update'
  get ':username/data_distributions/:id/edit' => 'data_distributions#edit'
  post ':username/data_distributions/:id/star' => 'data_distributions#star'
  post ':username/data_distributions/:id/unstar' => 'data_distributions#star'
  
  get 'transformations/new' => 'transformations#new'
  post 'transformations' => 'transformations#create'
  get ':username/transformations' => 'transformations#index'
  get ':username/transformations/:id' => 'transformations#show'
  delete ':username/transformations/:id' => 'transformations#destroy'
  put ':username/transformations/:id' => 'transformations#update'
  patch ':username/transformations/:id' => 'transformations#update'
  get ':username/transformations/:id/edit' => 'transformations#edit'
  post ':username/transformations/:id/star' => 'transformations#star'
  post ':username/transformations/:id/unstar' => 'transformations#unstar'

  get 'explore' => 'public_portal#explore'
  get 'publish' => 'data_distributions#publish'
  get 'quotas' => 'quotas#index'
  get 'dashboard' => 'dashboard#index'

  get ':username' => 'public_portal#user'


  
  # resources :transformations
  # resources :stars

  root to: 'public_portal#explore'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
