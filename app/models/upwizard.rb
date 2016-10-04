class Upwizard < ApplicationRecord
  belongs_to :user
  attachment :file

  validates :user, presence: true

end
