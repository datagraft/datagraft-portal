Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :cookie
  strategy :active_record
  strategy :default

  # Other strategies:
  #
  # strategy :query_string
  # strategy :redis
  # strategy :session
  #
  # strategy :my_strategy do |feature|
  #   # ... your custom code here; return true/false/nil.
  # end

  # Declare your features, e.g:
  #
  # feature :world_domination,
  #   default: true,
  #   description: "Take over the world."
  
  feature :activity_feed,
  default: false,
  description: "Show the activity feed in the dashboard."
  
  feature :catalogues,
  default: false,
  description: "Catalogues APIs and UI features shown in the UI."
  
  feature :queriable_data_stores,
  default: false,
  description: "Queriable data stores APIs and UI features shown in the UI."
  
  feature :utility_functions,
  default: false,
  description: "Utility functions APIs and UI features shown in the UI."
  
  feature :widgets,
  default: false,
  description: "Widgets APIs and UI features shown in the UI."

  feature :stars,
  default: false,
  description: "Stars APIs and UI features shown in the UI."
  
end
