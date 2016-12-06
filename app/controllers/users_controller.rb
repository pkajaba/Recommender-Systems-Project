class UsersController < ApplicationController
  def show
    if current_user.nil?
      redirect_to login_url, notice: 'You must login first.'
    else
      @categories = Category.all
      @category_hash = Hash.new { |h, k| h[k]=[] }
      user = User.find(current_user.id)
      puts user.id
      puts user.ratings.length
      user.ratings.each do |rating|
        @category_hash[rating.joke.category.id] << rating.joke
        puts @category_hash[rating.joke.category.id]
      end
    end
  end

  def about

  end

  def create
    puts user_params
    user = User.find_by(name: user_params[:name])
    if user != nil
      session[:user_id] = user.id
      redirect_to recommend_joke_path, notice: 'Úspešne ste sa prihlásil :), hurá do hodnotenia.'
    else
      user = User.new(user_params)
      respond_to do |format|
        if user.save
          session[:user_id] = user.id
          format.html { redirect_to recommend_joke_path, notice: 'Úspešne ste sa prihlásil :), hurá do hodnotenia.' }
          format.json { render :index, status: :created, location: @category }
        else
          format.html { edirect_to recommend_joke_path, notice: 'Uzivatel sa uspesne prihlasil' }
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
    params.require(:user).permit(:name)
  end

end