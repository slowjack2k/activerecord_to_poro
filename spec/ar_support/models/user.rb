class User < ActiveRecord::Base
  has_many :roles
  belongs_to :salutation

  def zz
    ActiveRecord::Base.new
  end
end