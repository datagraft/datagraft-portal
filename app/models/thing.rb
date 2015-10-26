class Thing < ActiveRecord::Base
  has_many :stars
  belongs_to :user
end

class DataDistribution < Thing; end
class DataTransformation < Thing; end
# class UtilityFunction < Thing;
class DataPage < Thing; end
class Query < Thing; end
class Widget < Thing; end
