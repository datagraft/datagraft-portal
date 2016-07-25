Rails.application.routes.draw do



  resources :features, only: [ :index ] do
    resources :strategies, only: [ :update, :destroy ]
  end
  mount Flip::Engine => "/features" rescue "no flip"

  use_doorkeeper

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
    }

  def datagraft_resources(resource_sym)
    resource = resource_sym.to_s
    context = ':username/'+resource
    context_id = context + '/:id'

    get    context + '/new' =>       resource + '#new'
    post   context =>                resource + '#create'
    get    context =>                resource + '#index'
    get    context_id =>             resource + '#show'
    delete context_id =>             resource + '#destroy'
    put    context_id =>             resource + '#update'
    patch  context_id =>             resource + '#update'
    get    context_id + '/edit' =>   resource + '#edit'
    post   context_id + '/star' =>   resource + '#star'
    post   context_id + '/unstar' => resource + '#unstar'
    post   context_id + '/fork' =>   resource + '#fork'
    get    context_id + '/versions' => resource + '#versions'

    ['metadata', 'configuration'].each do |type|
      full_context = context_id + '/' + type
      context_with_key = full_context + '/*key'
      resource_show = resource + '#show_' + type
      resource_edit = resource + '#edit_' + type
      resource_delete = resource + '#delete_' + type

      get    full_context => resource_show
      post   full_context => resource_edit
      put    full_context => resource_edit
      delete full_context => resource_delete

      get    context_with_key, to: resource_show, format: false
      post   context_with_key, to: resource_edit, format: false
      put    context_with_key, to: resource_edit, format: false
      delete context_with_key, to: resource_delete, format: false
    end

  end

  datagraft_resources :data_distributions
  datagraft_resources :data_pages
  datagraft_resources :transformations
  datagraft_resources :queries
  datagraft_resources :filestores
  datagraft_resources :sparql_endpoints

  # TODO fix me : Flip crashes on migration
  begin
    if Flip.on? :catalogues
      get ':username/catalogues/new' => 'catalogues#new'
      post ':username/catalogues' => 'catalogues#create'
      get ':username/catalogues' => 'catalogues#index'
      get ':username/catalogues/:id' => 'catalogues#show'
      delete ':username/catalogues/:id' => 'catalogues#destroy'
      patch ':username/catalogues/:id' => 'catalogues#update'
      put ':username/catalogues/:id' => 'catalogues#update'
      get ':username/catalogues/:id/edit' => 'catalogues#edit'
      post ':username/catalogues/:id/star' => 'catalogues#star_catalogue'
      post ':username/catalogues/:id/unstar' => 'catalogues#unstar_catalogue'
      get ':username/catalogues/:id/versions' => 'catalogues#versions'
    end


    if Flip.on? :queriable_data_stores
      datagraft_resources :queriable_data_stores
    end

    
    if Flip.on? :utility_functions
      datagraft_resources :utility_functions
    end
  rescue
    puts "No Flip"
  end

  get 'api_keys/first' => 'api_keys#first'
  resources :api_keys
  
  get 'explore' => 'public_portal#explore'
  get 'publish' => 'data_distributions#publish'
  get 'publishfilestore' => 'filestores#publish'
  get 'quotas' => 'quotas#index'
  get 'dashboard' => 'dashboard#index'
  get 'transform' => 'transformations#transform'
  get 'publish_queriable_data_store' => 'queriable_data_stores#publish'

  get ':username/data_distributions/:id/attachment' => 'data_distributions#attachment'
  get ':username/filestores/:id/attachment' => 'filestores#attachment'

  post ':username/queries/:id/execute/:qds_username/:qds_id' => 'queries#execute'
  get 'querying' => 'queries#execute'
  post 'querying' => 'queries#execute'

  # TODO REMOVE THIS LATER ?
  get ':username/queries/:id/execute/:qds_username/:qds_id' => 'queries#execute'


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
