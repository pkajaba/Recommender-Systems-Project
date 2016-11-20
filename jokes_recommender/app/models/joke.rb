class Joke < ApplicationRecord
  belongs_to :category
  has_many :ratings
  has_many :users, :through => :ratings
end
