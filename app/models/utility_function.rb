class UtilityFunction < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def license
    metadata["license"] if metadata
  end

  def license=(val)
    touch_metadata!
    metadata["license"] = val
  end

  def code
    configuration["code"] if not configuration
  end

  def code=(val)
    touch_configuration!
    configuration["code"] = val
  end
end
