class Category < ApplicationRecord
  validates :name, uniqueness: true

  has_many :jokes
  has_many :user_prefer_categories
end
