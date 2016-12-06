class RatingsController < ApplicationController

  def update
    @rating = Rating.find(params[:id])
    @joke = @rating.joke

    upf = UserPreferCategory.find_by(category_id: @joke.category.id, user_id: @current_user.id)
    if upf
      upf.update_attributes(total_rated_jokes: upf.total_rated_jokes + 1, total_rate: upf.total_rate + params[:user_rating])
    else
      UserPreferCategory.create(category_id: @joke.category.id, user_id: @current_user.id, total_rated_jokes: 1, total_rate: params[:user_rating])
    end

    if @rating.update_attributes(user_rating: params[:user_rating])
      respond_to do |format|
        format.js
      end
    end

  end

  def index
    #@ratings = Rating.find_by[user_id: current_user.id]
    @ratings = Rating.all
  end

end