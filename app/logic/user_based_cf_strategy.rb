class UserBasedCFStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    rankings = recommend_user_based
    if rankings.length == 0
      joke = recommend_random
    else
      joke, predicted_rating = rankings.first
    end
    joke
  end

  def recommend_random
    jokes = Joke.all - @user.jokes
    jokes[rand(jokes.length)]
  end

  def pearson_correlation(otherUser)
    #List of jokes rated by @user and otherUser
    commonJokes = Array.new
    @user.ratings.each do |rating|
      joke = rating.joke
      if otherUser.jokes.include?(joke)
        commonJokes.push(joke.id)
      end
    end

    n = commonJokes.length
    if n == 0
      return 0
    end

    #find @user ratings and other_user ratings for common jokes
    user_ratings=find_ratings(@user, commonJokes)
    other_user_ratings=find_ratings(otherUser, commonJokes)

    #sum of all user and other_user ratings
    user_ratings_sum = user_ratings.inject(0, :+)
    other_user_ratings_sum = other_user_ratings.inject(0, :+)

    #Sum of the squares of the ratings
    square_sum1 = user_ratings.map { |rating| rating ** 2 }.inject(0, :+)
    square_sum2 = other_user_ratings.map { |rating| rating ** 2 }.inject(0, :+)

    #Sum of the products of user ratings with other_user ratings
    product_sum = user_ratings.zip(other_user_ratings).map { |i, j| i*j }.inject(0, :+)

    #Computing of Pearson correlation coef.
    numerator = product_sum - (user_ratings_sum * other_user_ratings_sum/n)
    divider = Math.sqrt((square_sum1 - user_ratings_sum**2/n) * (square_sum2 - other_user_ratings_sum**2/n))
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
              totals[joke] += find_rating(user, joke) * sim
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
        rankings[joke] = sim_rating/similarity_sums[joke]
      end
    end
    rankings.sort_by { |_joke, ranking| ranking }.reverse
  end
end