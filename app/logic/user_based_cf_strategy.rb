class UserBasedCFStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    rankings = recommend_user_based
    if rankings.length == 0
      joke = recommend_random
      predicted_rating = @user.average
    else
      joke, predicted_rating = rankings.first
    end
    PredictedRating.create(joke_id: joke.id, user_id: @user.id, predicted_rating: predicted_rating)
    joke
  end

  def recommend_random
    jokes = Joke.all - @user.jokes
    jokes[rand(jokes.length)]
  end

  def pearson_correlation(otherUser)
    #List of jokes rated by @user and otherUser
    commonJokes = Array.new
    other_user_jokes = otherUser.jokes
    user_ratings = Array.new
    @user.ratings.each do |rating|
      joke = rating.joke
      if other_user_jokes.include?(joke)
        commonJokes.push(joke.id)
        user_ratings.push(rating.user_rating)
      end
    end
    commonJokes = @user.jokes & other_user_jokes

    n = commonJokes.length
    if n == 0
      return 0
    end

    #find @user ratings and other_user ratings for common jokes
    other_user_ratings=find_ratings(otherUser, commonJokes)

    #should not happen but it happened :D
    if (user_ratings.length != other_user_ratings.length)
      return 0
    end

    #sum of all user and other_user ratings
    user_ratings_sum = user_ratings.inject(0, :+)
    other_user_ratings_sum = other_user_ratings.inject(0, :+)

    #Sum of the squares of the ratings
    square_sum1 = user_ratings.map { |rating| rating ** 2 }.inject(0, :+)
    square_sum2 = other_user_ratings.map { |rating| rating ** 2 }.inject(0, :+)

    #Sum of the products of user ratings with other_user ratings
    product_sum = user_ratings.zip(other_user_ratings).map { |i, j| i*j }.inject(0, :+)

    #Computing of Pearson correlation coef.
    numerator = n*product_sum - (user_ratings_sum * other_user_ratings_sum)
    divider = Math.sqrt((n*square_sum1 - user_ratings_sum**2) * (n*square_sum2 - other_user_ratings_sum**2))
    if divider == 0
      return 0
    end

    numerator/divider
  end

  def find_ratings(user, jokes)
    Rating.select('user_rating').where(:user_id => user.id).where(:joke_id => jokes)
        .map { |rating| rating.user_rating }
  end

  def find_rating(user, joke)
    ratings = Rating.select('user_rating').where(:user_id => user.id).where(:joke_id => joke.id)
                  .map { |rating| rating.user_rating }
    ratings.first
  end

  def recommend_user_based
    totals = Hash.new
    similarity_sums = Hash.new
    User.all.each do |user|
      if user != @user
        sim = pearson_correlation(user)
        if sim > 0
          user.jokes.each do |joke|
            totals[joke] ||= 0
            similarity_sums[joke] ||= 0
            unless @user.jokes.include?(joke)
              totals[joke] += (find_rating(user, joke) - user.average) * sim
              similarity_sums[joke] += sim
            end
          end
        end
      end
    end

    #Make a prediction
    rankings = Hash.new
    totals.each do |joke, sim_rating|
      if similarity_sums[joke] > 0
        rankings[joke] = @user.average + sim_rating/similarity_sums[joke]
      end
    end
    rankings.sort_by { |_joke, ranking| ranking }.reverse
  end
end