class CreateMyArClass < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :salutation_id
    end

    create_table :roles do |t|
      t.string  :name
      t.integer :user_id
    end

    create_table :salutations do |t|
      t.string  :name
    end
  end
end
