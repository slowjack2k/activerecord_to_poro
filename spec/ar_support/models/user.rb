class User < ActiveRecord::Base
  has_many :roles, autosave: true
  has_many :permissions, through: :roles, autosave: true

  belongs_to :salutation, autosave: true
  has_one :address, autosave: true


end