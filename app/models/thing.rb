class Thing < ApplicationRecord
  extend FriendlyId
  include ThingHelper
  # friendly_id :name, :use => [:slugged, :simple_i18n, :history]
  # friendly_id :name, use: => [:slugged, :simple_i18n, :history, :scoped], :scope => :user
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  # friendly_id :name, :use => :history

  has_many :stars
  has_many :catalogues, :through => :catalogue_records
  belongs_to :user

  validates :name, presence: true
  validates :user, presence: true

  acts_as_taggable_on :keywords
  # As parents and children (forking stuff)
  has_closure_tree

  # Versionning
  has_paper_trail


  # Update metrics
  before_destroy :update_asset_metrics_destroy
  after_create_commit :increment_asset_metric


  # TODO update_asset_metrics_destroy and increment_asset_metric are not DRY ;(
  # updates asset number metrics (number of versions, decrements number of assets)
  def update_asset_metrics_destroy
    begin
      num_assets = Prometheus::Client.registry.get(:num_assets)
      curr_num_assets_metric_val = num_assets.get({asset_type: self.type, owner: self.user.username, access_permission: self.public ? 'public' : 'private'});
      num_assets.set({asset_type: self.type, owner: self.user.username, access_permission: self.public ? 'public' : 'private'}, curr_num_assets_metric_val - 1)
      update_asset_version_metric(self.type)
    rescue Exception => e
      puts 'Error decrementing num_assets metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end
  # increments number of assets metric
  def increment_asset_metric
    begin
      num_assets = Prometheus::Client.registry.get(:num_assets)
      curr_num_assets_metric_val = num_assets.get({asset_type: self.type, owner: self.user.username, access_permission: self.public ? 'public' : 'private'});
      num_assets.set({asset_type: self.type, owner: self.user.username, access_permission: self.public ? 'public' : 'private'}, curr_num_assets_metric_val + 1)
    rescue Exception => e
      puts 'Error incrementing num_assets metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end

  # We overload the write_attribute function to correctly update attribute-related metrics
  def write_attribute(attr_name, value)
    if attr_name == 'public'
      public_private_changed(attr_name, read_attribute(attr_name), value)
    end
    super
  end

  # if asset permissions change, we update metric accordingly
  def public_private_changed (attr_name, old_value, new_value)
    begin
      num_assets = Prometheus::Client.registry.get(:num_assets)
      # decrement metric for old value
      curr_num_assets_metric_old_val = num_assets.get({asset_type: self.type, owner: self.user.username, access_permission: old_value ? 'public' : 'private'});
      num_assets.set({asset_type: self.type, owner: self.user.username, access_permission: old_value ? 'public' : 'private'}, curr_num_assets_metric_old_val - 1)

      if !new_value.in? [true, false] then
        ##if new_value new_value.in? ["1", "0"] then
        if new_value.in? ["1", "0"] then
          new_value = !new_value.to_i.zero?
        else
          # new value neither string nor boolean - should not happen
          throw "Invalid value for user access attribute"
        end
        end

        # increment metric for new value - for some reason we don't receive a boolean here...
        curr_num_assets_metric_val = num_assets.get({asset_type: self.type, owner: self.user.username, access_permission: new_value ? 'public' : 'private'});


        num_assets.set({asset_type: self.type, owner: self.user.username, access_permission: new_value ? 'public' : 'private'}, curr_num_assets_metric_val + 1);
      rescue Exception => e
        puts 'Error decrementing num_assets metric'
        puts e.message
        puts e.backtrace.inspect
      end
      end

      def self.public_list
        # returns a default registry
        Thing.where(
          :public => true,
          :type => ['DataPage', 'SparqlEndpoint', 'Transformation', 'DataDistribution', 'Filestore', 'Query', *('QueriableDataStore' if Flip.on? :queriable_data_stores), *('Widget' if Flip.on? :widgets)]
          )
        .order(stars_count: :desc, created_at: :desc).includes(:user)

      end

      def self.public_search(search)
        # ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
        self.public_list
        .basic_search({name: search, metadata: search}, false)
        # .fuzzy_search(name: search)
      end

      def fork(newuser)
        self.deep_clone do |original, copy|
          copy.user = newuser
          copy.stars_count = 0
          copy.public = false
          original.add_child copy
          increment_forks_metric(original)
          copy.resync_keyword_list
        end
      end

      def increment_forks_metric(thing)
        begin
          num_forks = Prometheus::Client.registry.get(:num_forks)
          curr_num_forks = num_forks.get({asset_type: self.type})

          curr_num_forks = 0 if !curr_num_forks
          num_forks.set({asset_type: self.type}, curr_num_forks + 1)
        rescue Exception => e
          puts 'Error decrementing num_forks metric'
          puts e.message
          puts e.backtrace.inspect
        end
      end

      # should we call this at all?
      def decrement_forks_metric(thing)
        num_forks = Prometheus::Client.registry.get(:num_forks)
        curr_num_forks = num_forks.get({asset_type: self.type})
        num_forks.set({asset_type: self.type}, curr_num_forks - 1)
      end

      def has_metadata?(key)
        !get_metadata(key).nil?
      end

      def get_metadata(key)
        # throw metadata
        Rodash.get(metadata, key)
      end

      def description
        metadata["description"] if metadata
      end

      def description=(val)
        touch_metadata!
        metadata["description"] = val
      end

      # meta_keyword_list is a string with comma separated keywords.
      # This string is stored in the metadata and trigges update of gem paper_trail version
      # The same string is also pushed to gem acts_as_taggable_on managing keywords
      # The result is the same information at both places.
      # When reading from meta_keyword_list the information is taken from the metadata
      # The result is that rollback to older version can fetch correct keywords.
      def meta_keyword_list
        unless metadata.blank?
          ret = metadata['keyword_list']
        end
        if ret == nil
          ret = ''
        end
        puts "Has keyword_list <"+self.keyword_list.to_s+">"
        puts "Read meta_keyword_list <"+ret+">"
        return ret
      end

      def meta_keyword_list=(keyw_list)
        touch_metadata!
        #puts "Write1 meta_keyword_list <"+keyw_list+">"
        self.keyword_list = keyw_list
        keyw_list_2 = self.keyword_list.to_s
        #puts "Write2 meta_keyword_list <"+keyw_list_2+">"
        metadata['keyword_list'] = keyw_list_2
      end

      #Get the keywords from metadata and write to acts_as_taggable_on
      #This is needed when doing fork
      def resync_keyword_list
        self.meta_keyword_list= self.meta_keyword_list
      end

      def has_children?
        return !self.children.empty?
      end

      protected
      def touch_metadata!
        self.metadata = {} if not metadata.is_a?(Hash)
      end

      def touch_configuration!
        self.configuration = {} if not configuration.is_a?(Hash)
      end
    end

    # class Query < Thing; end
    # class Widget < Thing; end
    # class UtilityFunction < Thing;
