class ItemBasedCFStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    jokes = Joke.all - @user.jokes
    jokes[rand(jokes.length)]
  end
end