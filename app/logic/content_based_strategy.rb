class ContentBasedStrategy
  def initialize

  end

  def recommend_next(user)
    user.ratings

    jokes = Joke.all - user.jokes
    jokes[rand(jokes.length)]
  end

end