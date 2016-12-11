class ChangeRatingToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :predicted_ratings, :predicted_rating, :float
  end
end
