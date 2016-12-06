class Rating < ApplicationRecord
  belongs_to :joke
  belongs_to :user

  def self.default_scope
    order(created_at: :desc)
  end
end
