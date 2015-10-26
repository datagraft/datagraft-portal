class Thing < ActiveRecord::Base
  has_many :stars
  belongs_to :user

  validates :name, presence: true
end

class DataPage < Thing; end
class Query < Thing; end
class Widget < Thing; end
# class UtilityFunction < Thing;
