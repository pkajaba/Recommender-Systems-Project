class RemoveSuggestedRatingFromRatings < ActiveRecord::Migration[5.0]
  def change
    remove_column :ratings, :suggested_rating, :integer
  end
end
