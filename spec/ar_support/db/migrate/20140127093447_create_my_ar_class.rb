class CreateMyArClass < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :salutation_id
      t.integer :lock_version
    end

    create_table :roles do |t|
      t.string  :name
      t.integer :user_id
      t.integer :lock_version
    end

    create_table :permissions do |t|
      t.string  :name
      t.integer :role_id
      t.integer :lock_version
    end

    create_table :salutations do |t|
      t.string  :name
      t.integer :lock_version
    end

    create_table :addresses do |t|
      t.string  :street
      t.integer :user_id
      t.integer :lock_version
    end
  end
end
