class UserBasedCFStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    user.ratings
  end
end