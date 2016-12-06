class ContentBasedStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    preferring_factor = 4 #ako velmi chceme aby vyberalo categorie nad priemernym hodnotenim
    variance = 0.3 # ako daleko od odhadovanej dlzky budeme schvalovat
    approximated_length = select_approximated_length # odhadovana dlzka vtipu
    select_joke(preferring_factor, variance, approximated_length)
  end

  # TODO myslim ze toto je naivne
  def select_approximated_length
    total = 0.0
    number = 0.0
    @user.ratings.each do |rating|
      total += rating.user_rating * joke.content.length
      number += rating.user_rating
    end
    (total / number).floor
  end

  def select_joke(preferring_factor, variance, approximated_length, prohibited_categories = [])
    if prohibited_categories.length = Category.all.length # increase variance if we didnt find suitable joke in any category
      prohibited_categories = []
      variance *= 2
    end
    category = select_category(preferring_factor, prohibited_categories) # find category
    joke = find_joke_in_category(category, approximated_length, variance) # tryto find joke in category
    joke ||= select_joke(preferring_factor, variance, approximated_length, prohibited_categories.push(category)) # if we didnt find go recursive without this category
  end

  def select_category(preferring_factor = 1, prohibited_categories = [])
    possible_categories = Category.all - prohibited_categories # selects possible categories
    user_prefered_categories = @user.user_prefer_categories.map { |upf| upf.category } # selects user rated categories
    user_average = @user.user_prefer_categories.inject(0) { |sum, x| sum + x.average_rate } / @user.user_prefer_categories.length.to_f # calculate average rating of user rated categories

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

  def find_joke_in_category(category, approximated_length, variance)
    rated_jokes = @user.jokes.select { |joke| joke.category.id = category.id }
    all_jokes = category.jokes
    possible_jokes = all_jokes - rated_jokes
    joke = possible_jokes.bsearch { |joke| approximated_length - approximated_length*variance <= joke.content.length <= approximated_length + approximated_length*variance }
  end

  #TODO ak odpovedal na vsekt vtipy tak zamrzneme
  #TODO mozno ||= rekurzivne vola -> zavisi ci je lazy evaluation

end