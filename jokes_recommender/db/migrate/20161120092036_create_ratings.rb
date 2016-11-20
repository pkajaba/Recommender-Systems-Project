class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.references :joke, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :user_rating
      t.integer :suggested_rating
      t.timestamps
    end
  end
end
