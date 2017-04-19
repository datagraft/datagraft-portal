Rails.application.routes.draw do



  get 'landingpage/index'

  resources :features, only: [ :index ] do
    resources :strategies, only: [ :update, :destroy ]
  end
  mount Flip::Engine => "/features" rescue "no flip"

  use_doorkeeper

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
    }

  get 'api_keys/first' => 'api_keys#first'
  resources :api_keys

  get 'explore' => 'public_portal#explore'
  get 'news' => 'public_portal#news'
  get 'documentation' => 'public_portal#documentation'
  get 'api' => 'public_portal#api'
  get 'feedback' => 'public_portal#feedback'
  get 'about-us' => 'public_portal#about'
  get 'terms-of-use' => 'public_portal#terms'
  get 'privacy-policy' => 'public_portal#privacy'
  get 'cookie-policy' => 'public_portal#cookie'
  get 'faq' => 'public_portal#faq'

#  get 'publish' => 'data_distributions#publish'
#  get 'publishfilestore' => 'filestores#publish'
  get 'quotas' => 'quotas#index'
  get 'dashboard' => 'dashboard#index'
  get 'transform' => 'transformations#transform'
#  get 'publish_queriable_data_store' => 'queriable_data_stores#publish'

#  get ':username/data_distributions/:id/attachment' => 'data_distributions#attachment'
  get ':username/filestores/:id/attachment' => 'filestores#attachment'
  get ':username/filestores/:id/preview' => 'filestores#preview'
 post ':username/filestores/:id/preview' => 'filestores#preview'
  get ':username/filestores/new/:wiz_id' => 'filestores#new'

  post ':username/queries/:id/execute/:qds_username/:qds_id' => 'queries#execute'
  get 'querying' => 'queries#execute'
  post 'querying' => 'queries#execute'

  post ':username/queries/:id/execute_query' => 'queries#execute_query'
  get ':username/sparql_endpoints/new/:wiz_id' => 'sparql_endpoints#new'
  post ':username/sparql_endpoints/:id/execute_query' => 'sparql_endpoints#execute_query'


  get    ':username/upwizards'             => 'upwizards#index'   #List all wizards
  get    ':username/upwizards/new/:task'   => 'upwizards#new'     #Start a new wizard for a task
  get    ':username/upwizards/:wiz_id/attachment' => 'upwizards#attachment' #Download attachment
  post   ':username/upwizards/:id/:wiz_id' => 'upwizards#create'  #Upload a file
  get    ':username/upwizards/:id/:wiz_id' => 'upwizards#show'    #Show the current step
  get    ':username/upwizards/:id/:wiz_id/debug' => 'upwizards#debug'    #Show debug information
  delete ':upwizards/:wiz_id' => 'upwizards#destroy'
  put    ':username/upwizards/:id/:wiz_id' => 'upwizards#update'
  patch  ':username/upwizards/:id/:wiz_id' => 'upwizards#update'


  # TODO REMOVE THIS LATER ?
  get ':username/queries/:id/execute/:qds_username/:qds_id' => 'queries#execute'


  #get ':username' => 'public_portal#user'

  root to: 'landingpage#index'

  scope ':username' do

    root "public_portal#user"

    def datagraft_resources(resource_sym)
      resource_name = resource_sym.to_s
      resource_and_context = resource_name + '/:id'
      patch resource_and_context => resource_name + '#update_partial'
      resources resource_sym, :except => :patch do
        member do
          get  'versions'
          post 'star'
          post 'unstar'
          post 'fork'

          ['metadata', 'configuration'].each do |type|

            resource_show = type + '#show'
            resource_edit = type + '#create'
            resource_delete = type + '#delete'

            scope type do
              root         resource_show
              post   '' => resource_edit
              put    '' => resource_edit
              delete '' => resource_delete

              get    '/*key' => resource_show,   format: false
              post   '/*key' => resource_edit,   format: false
              put    '/*key' => resource_edit,   format: false
              delete '/*key' => resource_delete, format: false
            end
          end
        end
      end
    end

#    datagraft_resources :data_distributions
#    datagraft_resources :data_pages
    datagraft_resources :transformations
    datagraft_resources :queries
    datagraft_resources :filestores
    datagraft_resources :sparql_endpoints

    # TODO fix me : Flip crashes on migration
    begin
#      if Flip.on? :catalogues
#        resources :catalogues do
#          member do
#            get 'versions'
#            post 'star'
#            post 'unstar'
#          end
#        end
#      end

#      if Flip.on? :queriable_data_stores
#        datagraft_resources :queriable_data_stores
#      end


#      if Flip.on? :utility_functions
#        datagraft_resources :utility_functions
#      end
    rescue
      puts "No Flip"
    end
  end

end
