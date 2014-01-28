class User < ActiveRecord::Base
  has_many :roles
  has_many :permissions, through: :roles

  belongs_to :salutation
  has_one :address


end