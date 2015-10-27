class Transformation < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => :user

  def should_generate_new_friendly_id?
    name_changed? || super
  end

end
