class UsersController < ApplicationController
  def show
    @categories = Category.all
  end

  def about

  end
end