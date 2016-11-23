require 'random_strategy'
require 'item_based_cf_strategy'

class RecommenderStrategy
  @@random_strategy = RandomStrategy.new
  @@item_based_cf_strategy = ItemBasedCFStrategy.new

  def self.random_strategy
    @@random_strategy
  end

  def self.item_based_cf_strategy
    @@item_based_cf_strategy
  end

  def self.randomize
    rand(2)
  end

  def self.strategy_by_number(number)
    case number
      when 0
        random_strategy
      when 1
        item_based_cf_strategy
      else
        random_strategy
    end
  end

end