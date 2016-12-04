class RatingsController < ApplicationController

  def update
    @rating = Rating.find(params[:id])
    @joke = @rating.joke
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