class Role < ActiveRecord::Base
  has_many :permissions, autosave: true
  belongs_to :user
end