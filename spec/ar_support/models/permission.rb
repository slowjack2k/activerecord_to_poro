class Permission < ActiveRecord::Base
  belongs_to :role, autosave: true
end