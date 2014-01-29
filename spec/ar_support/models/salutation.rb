class Salutation < ActiveRecord::Base
  has_many :users, autosave: true
end