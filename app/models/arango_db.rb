class ArangoDb < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :sparql_endpoint_queries, dependent: :destroy
  has_many :queries, :through => :sparql_endpoint_queries

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true

  # Non-persistent attribute for storing query to be executed
  attr_accessor :execute_query
  #attr_accessor :publish_file

  #after_create_commit :initialised_sparql_endpoint

  #def initialised_sparql_endpoint
  #  self.pass_parameters
  #end

  # Check if user has db account
  def has_dbm?
    dbm != nil
  end

  def dbm_id
    res = nil
    d = dbm
    res = d.id unless d == nil
    return res
  end

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def db_entries=(val)
    #Do nothing...
  end

  def db_entries
    #Return Dummy
    return 1001
  end


  def db_name
    metadata["db_name"] if metadata
  end

  def db_name=(val)
    touch_metadata!
    attribute_will_change!('db_name') if db_name != val
    metadata["db_name"] = val
  end

end
