class Thing < ApplicationRecord
  extend FriendlyId
  include ThingHelper
  # friendly_id :name, :use => [:slugged, :simple_i18n, :history]
  # friendly_id :name, use: => [:slugged, :simple_i18n, :history, :scoped], :scope => :user
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  # friendly_id :name, :use => :history

  has_many :stars, dependent: :destroy
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
  after_create_commit :update_asset_metric
  after_update :update_public_private_metrics

  def update_asset_metrics_destroy
    begin
      reset_num_assets(self, -1)
      update_asset_version_metric(self.type)
    rescue Exception => e
      puts 'Error decrementing num_assets metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end

  # increments number of assets metric
  def update_asset_metric
    begin
      reset_num_assets(self, 0)
      update_asset_version_metric(self.type)
    rescue Exception => e
      puts 'Error incrementing num_assets metric'
      puts e.message
      puts e.backtrace.inspect
    end
  end
  
  # on each asset update we update the number of private/public assets
  def update_public_private_metrics
    reset_num_assets_public_private(self)
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
      if original.type == 'Filestore'
        unless original.file == nil
          begin
            # This procedure is needed to force refile to copy the attachement
            tmp_file = Refile.store.upload(original.file)
            copy.update(file_id: tmp_file.id)
          rescue Exception => e
            puts 'Fork cannot copy attachement. Cause:<'+e.message+'>'
          end
        end
      end
    end
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

  def download_count
    unless metadata.blank?
      ret = metadata["download_count"]
    end
    if ret == nil
      ret = 0
    end
    return ret
  end

  def inc_download_count
    touch_metadata!
    metadata["download_count"] = download_count + 1
  end

  def preview_count
    unless metadata.blank?
      ret = metadata["preview_count"]
    end
    if ret == nil
      ret = 0
    end
    return ret
  end

  def inc_preview_count
    touch_metadata!
    metadata["preview_count"] = preview_count + 1
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
