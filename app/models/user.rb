class User < ActiveRecord::Base
  include OntotextUser

  has_many :stars
  has_many :catalogue_stars
  has_many :transformations
  has_many :data_distributions
  has_many :queriable_data_stores
  has_many :data_pages
  has_many :api_keys
  has_many :catalogues
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :github]

  # Username constraints
  validates :username, uniqueness: true, case_sensitive: false
  validates :username, length: { in: 3..140 }
  validates :username, exclusion: {
    in: %w(datagraft user users distribution distributions transformation transformations datapage datapages query queries widget widgets function functions catalogue catalogues),
    message: "\"%{value}\" is reserved."
  }

  validates :username, format: {
    with: /[a-zA-Z0-9_-]+/,
    message: "only allows letters, numbers, underscores, and dashes" }

  # Caca de taureau
  validates :terms_of_service, acceptance: true 

  validates :website, :url => {:allow_blank => true}

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
    Thing.where(user: self).order(stars_count: :desc, created_at: :desc)
  end

  def dashboard_catalogues
    Catalogue.where(user: self).order(stars_count: :desc, created_at: :desc)
  end
    
  def search_dashboard_things(search)
    ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
    dashboard_things.fuzzy_search(name: search)
  end
  
  def search_dashboard_catalogues(search)
    ActiveRecord::Base.connection.execute("SELECT set_limit(0.1);")
    dashboard_catalogues.fuzzy_search(name: search)
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
end
