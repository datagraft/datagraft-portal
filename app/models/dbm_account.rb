class DbmAccount < ApplicationRecord
  belongs_to :dbm
  belongs_to :user
end
