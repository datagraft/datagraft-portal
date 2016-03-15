class Transformation < Thing
  extend FriendlyId
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]
  # friendly_id :name, :use => :history

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def code
    configuration["code"] unless configuration.blank?
  end

  def code=(val)
    touch_configuration!
    configuration["code"] = val
  end

end
