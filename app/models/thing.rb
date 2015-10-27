class Thing < ActiveRecord::Base
  extend FriendlyId
  # friendly_id :name, :use => [:slugged, :simple_i18n, :history]
  # friendly_id :name, use: => [:slugged, :simple_i18n, :history, :scoped], :scope => :user
  friendly_id :name, :use => [:history, :scoped], :scope => :user

  has_many :stars
  belongs_to :user

  validates :name, presence: true

  has_paper_trail

end

class DataPage < Thing; end
class Query < Thing; end
class Widget < Thing; end
# class UtilityFunction < Thing;
