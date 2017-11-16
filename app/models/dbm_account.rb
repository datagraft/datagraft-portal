class DbmAccount < ApplicationRecord
  belongs_to :dbm
  belongs_to :user

  def has_configuration?(key)
    !get_configuration(key).nil?
  end

  def get_configuration(key)
    # throw configuration
    Rodash.get(configuration, key)
  end

  #def name
  #  get_configuration("mock_name")
  #end

  #def name=(val)
  #  touch_configuration!
  #  configuration["mock_name"] = val
  #end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end


end
