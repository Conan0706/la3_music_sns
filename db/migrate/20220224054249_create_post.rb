class CreatePost < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :artist
      t.string :album
      t.string :title
      t.string :jacket
      t.string :sample
      t.text :comment
    end
  end
end
