class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :rating
      t.text :comment
      t.integer :movie_id

      t.timestamps
    end
  end
end
