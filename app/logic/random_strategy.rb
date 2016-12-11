class RandomStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    jokes = Joke.all - @user.jokes
    joke = jokes[rand(jokes.length)]
    PredictedRating.create(joke_id: joke.id, user_id: @user.id, predicted_rating: @user.average)
    joke
  end
end