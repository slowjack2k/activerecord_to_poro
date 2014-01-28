class Role < ActiveRecord::Base
  has_many :permissions
  belongs_to :user
end