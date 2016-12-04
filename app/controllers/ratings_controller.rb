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

end