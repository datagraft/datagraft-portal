class SparqlEndpoint < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  has_many :sparql_endpoint_queries, dependent: :destroy
  has_many :queries, :through => :sparql_endpoint_queries

  accepts_nested_attributes_for :queries, reject_if: :all_blank, :allow_destroy => true

  # Non-persistent attribute for storing query to be executed
  attr_accessor :execute_query
  attr_accessor :publish_file

  after_create_commit :initialised_sparql_endpoint

  def initialised_sparql_endpoint
    self.pass_parameters
  end

  # Check if user has db account
  def has_rdf_repo?
    rdf_repo != nil
  end

  def dbm
    res = nil
    unless rdf_repo == nil
      res = rdf_repo.dbm
    end
    return res
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

  def write_attribute(attr_name, value)
    # Check if new (no user) or update (existing user)
    if self.user != nil and attr_name == 'public'
      old_value = self.read_attribute(attr_name)
      super
      new_value = self.read_attribute(attr_name)

      # Update public/private property if changed
      if new_value != old_value
        if self.has_rdf_repo?
          self.rdf_repo.update_repository_public(self.public)
        end
      end
    else
      super
    end
  end

  def dbm_entries=(val)
    #Do nothing...
  end

  def dbm_entries
    #Return Dummy
    return 1001
  end


  state_machine :initial => :created do

    # pass the parameters to the initialisation function
    event :pass_parameters do
      transition :created => :initialised
    end

    # issue the request to create the new repository in S4
    event :issue_create_repo do
      transition :initialised => :creating_repo
    end

    # something went wrong while creating repository
    event :error_occured_creating_repo do
      transition all => :error_creating_repo
    end

    # retry creating the repository when an error occured
    event :retry_creating_repo do
      transition :error_creating_repo => :creating_repo
    end

    # repository has been successfully created and attached
    event :repo_successfully_created do
      transition :creating_repo => :repo_created
    end


    # Created the endpoint object - initial state
    state :created do
      def uri
        "Initialise first."
      end
      def cached_size
        return '0'
      end
    end

    # initialised the endpoint with basic required metadata
    state :initialised do
      def uri
        "No URI yet."
      end
      def cached_size
        return '0'
      end
    end

    # in the process of creating a repository to attach to endpoint; may take some time
    state :creating_repo do
      def uri
        "Creating repository. Please wait..."
      end
      def cached_size
        return '0'
      end
    end

    # some error occured while creating the repository
    state :error_creating_repo do
      def uri
        "No URI yet."
      end
      def cached_size
        return '0'
      end
    end

    # repository successfully created and attached
    state :repo_created do
      def uri
        if self.has_rdf_repo?
          self.rdf_repo.uri
        else
          metadata["uri"] if metadata
        end
      end

      def cached_size
        result = nil
        result = metadata["cached_size"] if metadata
        return (result ||= '0')
      end

      def cached_size=(val)
        touch_metadata!
        metadata["cached_size"] = val ||= 0
      end
    end
  end

  def uri=(val)
    touch_metadata!
    attribute_will_change!('uri') if uri != val
    metadata["uri"] = val
  end

end
