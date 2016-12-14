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
      joke = Joke.find(joke)
    end
    PredictedRating.create(joke_id: joke.id, user_id: @user.id, predicted_rating: predicted_rating)
    joke
  end

  def recommend_random
    jokes = Joke.all - @user.jokes
    jokes[rand(jokes.length)]
  end

  def pearson_correlation(otherUser)
    common_jokes = @user.jokes & otherUser.jokes

    n = common_jokes.length
    if n == 0
      return [0, common_jokes]
    end

    #find @user ratings and other_user ratings for common jokes
    other_user_ratings_raw = find_ratings(otherUser, common_jokes).map { |rating| rating.user_rating }
    user_ratings_raw = find_ratings(@user, common_jokes).map { |rating| rating.user_rating }
    other_user_ratings = other_user_ratings_raw.uniq {|rating| rating.joke.id}
    user_ratings = user_ratings_raw.uniq {|rating| rating.joke.id}
    #should not happen but it happened :D
    if (user_ratings.length != other_user_ratings.length)
      return [0, common_jokes]
    end
    
    numerator = user_ratings.zip(other_user_ratings).map { |i, j| (i- user.average)*(j-otherUser.average)}
                    .inject(0, :+)
    divider_user = other_user_ratings.map {
        |rating| (rating- otherUser.average)**2}.inject(0, :+)
    divider_other = user_ratings.map {
        |rating| (rating- user.average)**2}.inject(0, :+)

    divider = Math.sqrt(divider_user)*Math.sqrt(divider_other)

    if divider == 0
      return [0, common_jokes]
    end
    [numerator/divider, common_jokes]
  end

  def find_ratings(user, jokes)
    Rating.where(:user_id => user.id).where(:joke_id => jokes)
  end

  def find_rating(user, joke)
    ratings = Rating.where(:user_id => user.id).where(:joke_id => joke.id)
                  .map { |rating| rating.user_rating }
    ratings.first
  end

  def recommend_user_based
    totals = Hash.new
    similarity_sums = Hash.new
    sims = (User.all - [@user]).map do |user|
      temp = pearson_correlation(user)
      {sim: temp[0], user: user, common_jokes: temp[1]}
    end

    sims.sort! { |a, b| a[:sim] <=> b[:sim] }
    sims.last(5).each do |s|
      if s[:sim] != 0
        user = s[:user]
        sim = s[:sim]
        (user.jokes - s[:common_jokes]).each do |joke|
          totals[joke.id] ||= 0
          similarity_sums[joke.id] ||= 0
          totals[joke.id] += (find_rating(user,joke) - user.average) * sim
          similarity_sums[joke.id] += sim
        end
      end
    end

    #Make a prediction
    rankings = Hash.new
    totals.each do |joke_id, sim_rating|
      if similarity_sums[joke_id] > 0
        rankings[joke_id] = @user.average + sim_rating/similarity_sums[joke_id]
      end
    end
    rankings.sort_by { |_joke, ranking| ranking }.reverse
  end
end
