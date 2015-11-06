Rails.application.routes.draw do
  resources :api_keys
  resources :data_distributions

  resources :stars
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  #get ':kind/:username/:id' => 'transformations#show'
  #delete ':kind/:username/:id' => 'transformations#destroy'
  #get ':kind/:username/:id/edit' => 'transformations#edit'

  get 'data_distributions/new' => 'data_distributions#new'
  get ':kind/new' => 'transformations#new'
  post ':kind' => 'transformations#create'
  get ':username/:kind' => 'transformations#index'
  get ':username/:kind/:id' => 'transformations#show'
  delete ':username/:kind/:id' => 'transformations#destroy'
  put ':username/:kind/:id' => 'transformations#update'
  patch ':username/:kind/:id' => 'transformations#update'
  get ':username/:kind/:id/edit' => 'transformations#edit'

  get 'explore' => 'public_portal#explore'
  get ':username' => 'public_portal#user'
  
  resources :transformations
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
