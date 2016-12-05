class UserBasedCFStrategy
  def initialize

  end

  def recommend_next(user)
    user.ratings
  end
end