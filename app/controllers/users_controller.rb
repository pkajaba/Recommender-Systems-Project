require_relative '../logic/recommender_strategy.rb'

class UsersController < ApplicationController
  def show
    if current_user.nil?
      redirect_to login_url, notice: 'Musíš sa najprv prihlásiť'
    else
      @category_hash = Hash.new { |h, k| h[k]=[] }
      user = User.find(current_user.id)
      user.ratings.each do |rating|
        @category_hash[rating.joke.category.id] << rating.joke
      end
      @categories = Category.all.sort_by { |cat| @category_hash[cat.id].length }.reverse
      @cc = user.user_prefer_categories.sort_by {|upf| upf.total_rated_jokes }.reverse
    end
  end

  def about

  end

  def create
    puts user_params
    user = User.find_by(name: user_params[:name])
    if user != nil
      session[:user_id] = user.id
      redirect_to recommend_joke_path, notice: 'Úspešne si sa prihlásil :), hurá do hodnotenia.'
    else
      user = User.new(user_params)
      user.strategy = RecommenderStrategy.randomize
      respond_to do |format|
        if user.save
          session[:user_id] = user.id
          format.html { redirect_to recommend_joke_path, notice: 'Úspešne si sa prihlásil :), hurá do hodnotenia.' }
          format.json { render :index, status: :created, location: @category }
        else
          format.html { edirect_to recommend_joke_path, notice: 'Úspešne si sa prihlásil ' }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def login
    @user = User.new
  end

  private
  def user_params
    params.require(:user).permit(:name, :strategy)
  end

end