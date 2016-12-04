require 'random_strategy'
require 'item_based_cf_strategy'
require 'content_based_strategy'

class RecommenderStrategy
  @@random_strategy = RandomStrategy.new
  @@item_based_cf_strategy = ItemBasedCFStrategy.new
  @@content_based_strategy = ContentBasedStrategy.new

  def self.random_strategy
    @@random_strategy
  end

  def self.item_based_cf_strategy
    @@item_based_cf_strategy
  end

  def self.content_based_strategy
    @@content_based_strategy
  end



  def self.randomize
    rand(3)
  end

  def self.strategy_by_number(number)
    case number
      when 0
        random_strategy
      when 1
        item_based_cf_strategy
      when 2
        content_based_strategy
      else
        raise Exception
    end
  end

end