class Feature < ActiveRecord::Base
  extend Flip::Declarable

  strategy Flip::CookieStrategy
  strategy Flip::DatabaseStrategy
  strategy Flip::DeclarationStrategy
  default false


  feature :activity_feed,
  default: false,
  description: "Show the activity feed in the dashboard."
  
  feature :catalogues,
  default: false,
  description: "Catalogues APIs and UI features shown in the UI."
  
  feature :queriable_data_stores,
  default: true,
  description: "Queriable data stores APIs and UI features shown in the UI."
  
  feature :utility_functions,
  default: true,
  description: "Utility functions APIs and UI features shown in the UI."
  
  feature :widgets,
  default: false,
  description: "Widgets APIs and UI features shown in the UI."

  feature :stars,
  default: false,
  description: "Stars APIs and UI features shown in the UI."

end
