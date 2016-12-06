class UserPreferCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  def average_rate
    total_rate / total_rated_jokes.to_f
  end

end
