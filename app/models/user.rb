class User < ActiveRecord::Base
  has_many :stars
  has_many :transformations
  has_many :data_distributions
  has_many :data_pages
  has_many :api_keys
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :github]

  # Username constraints
  validates :username, uniqueness: true, case_sensitive: false
  validates :username, length: { in: 3..140 }
  validates :username, exclusion: {
    in: %w(datagraft user users distribution distributions transformation transformations datapage datapages query queries widget widgets function functions),
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

  def unstar(thing)
    Star.where(user: self, thing: thing).destroy
  end

  #def self.find_for_oauth(auth)
#
 # end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      puts auth.info
      p auth.info
      puts "J?AIME LES PONEYS AND VIVE LES RATS"
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
