class ContentBasedStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    preferring_factor = 3

    case @user.rating.length
      when 0..5
        #daky shuffle na 5 skupin vtipov a vyber z tej ktora este nebola
        joke = select_joke(select_category(preferring_factor), select_approximated_length())
      else
        #realne odporucaj podla hodnotenia jednotlivich v skupine

    end
  end

  def select_category(preferring_factor = 1, prohibited_categories = [])
    possible_categories = Category.all - prohibited_categories # selects possible categories
    user_prefered_categories = @user.user_prefer_categories.map {|upf| upf.category } # selects user rated categories
    user_average = @user.user_prefer_categories.inject(0){|sum,x| sum + x.average_rate } / @user.user_prefer_categories.length.to_f # calculate average rating of user rated categories

    evaluated_points = 0.0
    evaluated_categories = []
    possible_categories.each do |category|
      pos = user_prefered_categories.find_index(category)
      if pos
        category_average = @user.user_prefer_categories[pos].average_rate
        if category_average > user_average
          evaluated_categories.push([category, evaluated_points + category_average * preferring_factor]) # to prefer categories above average
          evaluated_points += category_average * preferring_factor
        else
          evaluated_categories.push([category, evaluated_points + category_average]) # to add categories under average
          evaluated_points += category_average
        end
      else
        evaluated_categories.push([category, evaluated_points + user_average]) # to add not rated categories
        evaluated_points += user_average
      end
    end

    selected_category = nil
    points = rand(evaluated_points.floor)
    evaluated_categories.bsearch_index { |x| x[1] > points } # to simulate choosing with different priorities
    selected_category
  end

  def select_approximated_length()

  end

  def select_joke(category, approximated_length)

  end


end