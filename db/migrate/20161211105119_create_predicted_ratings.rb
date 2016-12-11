class CreatePredictedRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :predicted_ratings do |t|
      t.integer :predicted_rating
      t.references :joke, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
