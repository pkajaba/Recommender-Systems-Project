class UsersController < ApplicationController
  def show
    @categories = Category.all
  end

  def about

  end

  # sneaky create
  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)

    respond_to do |format|
      if user.save
        format.html { redirect_to root_path, notice: 'User was successfully created.' }
        format.json { render :index, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:name)
  end
end