require 'random_strategy'
require 'item_based_cf_strategy'
require 'content_based_strategy'

class RecommenderStrategy

  def self.randomize
    users = User.all
    if users.length < 5
      0
    elsif users.length < 10
      1
    elsif users.length < 15
      2
    else
      rand(3)
    end
  end

  def self.strategy_by_number(user)
    case user.strategy
      when 0
        RandomStrategy.new user
      when 1
        ContentBasedStrategy.new user
      when 2
        ItemBasedCFStrategy.new user
      else
        raise Exception
    end
  end

end