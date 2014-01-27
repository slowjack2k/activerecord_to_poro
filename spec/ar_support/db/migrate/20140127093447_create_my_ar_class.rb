class CreateMyArClass < ActiveRecord::Migration
  def change
    create_table :my_ar_classes do |t|
      t.string :name
      t.string :email
    end
  end
end
