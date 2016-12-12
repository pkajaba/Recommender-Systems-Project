class RatingsController < ApplicationController

  def update
    @joke = Joke.find(params[:id])
    @rating = Rating.create(joke_id: @joke.id, user_id: current_user.id, user_rating: params[:user_rating])

    upf = UserPreferCategory.find_by(category_id: @joke.category.id, user_id: current_user.id)
    if upf
      upf.update_attributes(total_rated_jokes: upf.total_rated_jokes.to_i + 1, total_rate: upf.total_rate.to_i + params[:user_rating].to_i)
    else
      UserPreferCategory.create(category_id: @joke.category.id, user_id: current_user.id, total_rated_jokes: 1, total_rate: params[:user_rating].to_i)
    end

    #if @rating.update_attributes(user_rating: params[:user_rating])
    respond_to do |format|
      format.js
    end
    #end
  end

  def index
    #@ratings = Rating.find_by[user_id: current_user.id]
    @ratings = Rating.all
    @rr = @ratings.map { |rating| [rating, PredictedRating.find_by(user_id: rating.user.id, joke_id: rating.joke.id)] }
  end
end