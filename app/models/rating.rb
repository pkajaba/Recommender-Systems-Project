class Rating < ApplicationRecord
  belongs_to :joke
  belongs_to :user

  def default_scope
    order()
  end
end
