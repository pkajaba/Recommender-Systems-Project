class ItemBasedCFStrategy
  def initialize

  end

  def recommend_next(user)
    jokes = Joke.all - user.jokes
    jokes[rand(jokes.length)]
  end
end