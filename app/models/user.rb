class User < ApplicationRecord
  include UserHelper
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :stars, dependent: :destroy
  has_many :catalogue_stars, dependent: :destroy
  has_many :transformations, dependent: :destroy
  has_many :data_distributions, dependent: :destroy
  has_many :filestores, dependent: :destroy
  has_many :data_pages, dependent: :destroy
  has_many :utility_functions, dependent: :destroy
  has_many :queries, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :catalogues, dependent: :destroy
  has_many :sparql_endpoints, dependent: :destroy
  has_many :arango_dbs, dependent: :destroy
  has_many :upwizards, dependent: :destroy
  has_many :dbms, dependent: :destroy
  has_many :dbm_accounts, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :github]

  # Username constraints
  validates :username, uniqueness: true, case_sensitive: false
  validates :username, length: { in: 3..140 }
  validates :username, exclusion: {
    in: %w(
      datagraft test_user
      data_distribution data_distributions
      filestore filestores
      queriable_data_store queriable_data_stores
      data_page data_pages
      transformation transformations
      utility_function utility_functions
      sparql_endpoint sparql_endpoints
      arango_db arango_dbs
      query queries
      upwizard upwizards
      dbm dbms
      dbm_s4 dbm_s4s
      dbm_ontotext_leg dbm_ontotext_legs
      dbm_arango dbm_arangos
      dbm_account dbm_accounts
      api_key api_keys
      explore publish dashboard transform publish_queriable_data_store querying execute
      new edit index star unstar fork copy versions
      session logout login user users admin oauth
      stylesheets assets javascripts images
      configuration metadata
      myasset myassets public_asset public_assets),
    message: "\"%{value}\" is reserved."
  }

  validates :username, format: {
    with: /[a-zA-Z0-9_-]+/,
    message: "only allows letters, numbers, underscores, and dashes" }

  # Caca de taureau
  validates :terms_of_service, acceptance: true

  validates :website, :url => {:allow_blank => true}

  # register the decrease in number of users
  after_destroy :reset_num_users_metric

  # register the increase in number of users
  after_create :reset_num_users_metric

  def to_param
    self.username
  end

  def star(thing)
    star = Star.new
    star.user = self
    star.thing = thing
    star.save
  end

  def star_catalogue(catalogue)
    catalogue_star = CatalogueStar.new
    catalogue_star.user = self
    catalogue_star.catalogue = catalogue
    catalogue_star.save
  end

  def unstar(thing)
    Star.where(user: self, thing: thing).destroy_all
  end

  # def fork(thing)
  #   new_thing = thing.dup
  #   new_thing.stars_count = 0
  #   new_thing.user = self
  #   # false by default
  #   new_thing.public = false
  #   new_thing.save

  #   thing.add_child(new_thing)
  #   # new_thing.parent = thing
  #   # new_thing.save && thing.save
  #   return new_thing
  # end

  def unstar_catalogue(catalogue)
    CatalogueStar.where(user: self, catalogue: catalogue).destroy_all
  end

  def has_star(thing)
    Star.where(user: self, thing: thing).exists?
  end

  def has_catalogue_star(catalogue)
    CatalogueStar.where(user: self, catalogue: catalogue).exists?
  end

  def dashboard_things
    # TODO FIXME hack for filtering out previewed datasets using the name of the asset
    Thing.where(user: self).where.not("name LIKE ?", "%previewed_dataset_%").order(stars_count: :desc, created_at: :desc)
  end

  def dashboard_catalogues
    Catalogue.where(user: self).order(stars_count: :desc, created_at: :desc)
  end

  def search_dashboard_things(search)
    # ActiveRecord::Base.connection.execute("SELECT set_limit(0);")
    # dashboard_things.fuzzy_search(metadata: search)
    # dashboard_things.basic_search("cast(metadata as text)" => search)
    dashboard_things.basic_search({"metadata" => search, "name" => search}, false)#.fuzzy_search({name: search}, false)
    # dashboard_things.fuzzy_search("metadata->>a" => search)
    # dashboard_things.fuzzy_search("metadata" => search)
  end

  def search_dashboard_catalogues(search)
    # ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
    dashboard_catalogues.basic_search(name: search)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      puts auth.info
      p auth.info
      puts "J?AIME LES PONEYS AND VIVE LES RATS"
      puts "аз обичам мач и боза"
      user.terms_of_service = true
      user.username = auth.info.name.parameterize
      user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      # user.skip_confirmation!
      # user.skip_confirmation! if user.respond_to?(:skip_confirmation)
      user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      p session["devise.facebook_data"]
      p session["devise.github_data"]
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.username = data["name"].parameterize if user.username.blank?
      end

      if data = session["devise.github_data"]
        p data
        raw_info = session["devise.github_data"]["extra"]["raw_info"]
        user.email = data["info"]["email"] if user.email.blank?
        user.username = raw_info["login"].parameterize if user.username.blank?
      end
    end
  end

def search_for_existing_dbms_reptype(rep_type)
  res = []
  dbm_list = self.dbms.all
  dbm_list.each do |dbm|
    unless dbm.type == nil ## Only check specialisations
      srt = dbm.get_supported_repository_types
      res << dbm if srt.include? rep_type
    end
  end
  return res
end

def search_for_existing_dbms_type(type)
  res = self.dbms.where(type: type)
  return res
end



end
