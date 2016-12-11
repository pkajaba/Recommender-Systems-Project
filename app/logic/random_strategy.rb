class RandomStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    jokes = Joke.all - @user.jokes
    {joke: jokes[rand(jokes.length)], suggested_rating: @user.average}
  end
end