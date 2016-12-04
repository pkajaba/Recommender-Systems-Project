class UsersController < ApplicationController
  def show
    @categories = Category.all
    @category_hash = Hash.new {|h,k| h[k]=[]}
    current_user.ratings do |rating|
      @category_hash[rating.category.id] << rating.joke
    end
  end

  def about

  end

  def create
    puts user_params
    user = User.find_by(name: user_params[:name])
    if user != nil
      session[:user_id] = user.id
      render :about
    else
      user = User.new(user_params)
      respond_to do |format|
        if user.save
          session[:user_id] = user.id
          format.html { redirect_to root_path, notice: 'User was successfully created.' }
          format.json { render :index, status: :created, location: @category }
        else
          format.html { render :new }
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