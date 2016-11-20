class RecommenderStrategy
  def recommend_next(user)
    raise NotImplementedError, 'Ask the subclass'
  end
end