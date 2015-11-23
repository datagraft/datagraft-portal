class Transformation < Thing
  extend FriendlyId
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]
  # friendly_id :name, :use => :history

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  #def to_param
  #  "#{self.user_id}/#{self.id}"
  #end
end
