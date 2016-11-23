class RecommenderStrategy
  @@random_strategy = RandomStrategy.new
  @@item_based_cf_strategy = ItemBasedCFStrategy.new

  def random_strategy
    @@random_strategy
  end

  def item_based_cf_strategy
    @@item_based_cf_strategy
  end

  def randomize
    rand(2)
  end

  def strategy_by_number(number)
    case number
      when 0
        random_strategy
      when 1
        item_based_cf_strategy
      else
        raise Exception "invalid parameter #{number}"
    end
  end

end