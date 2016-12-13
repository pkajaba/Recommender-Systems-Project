require 'random_strategy'
require 'content_based_strategy'
require 'user_based_cf_strategy'

class RecommenderStrategy

  def self.randomize
    1
  end

  def self.strategy_by_number(user)
    case user.strategy
      when 0
        RandomStrategy.new user
      when 1
        ContentBasedStrategy.new user
      when 2
        UserBasedCFStrategy.new user
      else
        raise Exception
    end
  end

end