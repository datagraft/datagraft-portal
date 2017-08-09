module DbAccountThing
  #This module is to be included for all thing models that are connected to a db_account model for acessing a database

  # Things acting as XXX endpoints act as state machines so we can control the behavior of UI and backend
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
        metadata["uri"] if metadata
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

  # Things acting as XXX endpoints act as storage of repository access information.
  # The information is stored in a hash and the elements will be db_account specific
  def db_repository
    result = nil
    result = metadata["db_repository"] if metadata
    return (result ||= {})
  end

  def db_repository=(val)
    touch_metadata!
    attribute_will_change!('db_repository') if db_repository != val
    metadata["db_repository"] = val
  end



end
