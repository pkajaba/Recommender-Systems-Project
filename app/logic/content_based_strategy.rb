class ContentBasedStrategy
  def initialize user
    @user = user
    @all_categories = Category.all
  end

  def recommend_next
    variance = 0.1 # between 0 - inf +- kolko percent dlzky chceme hladat (1 = 100%)
    if @user.ratings.length < @all_categories.length / 5 # nazaciatku ziskam 1 rating pre 20% kategorii
      prohibited_categories = @user.ratings.map { |rating| rating.joke.category } # docielim ze na cold start kazda kategoria bude raz
      approximated_length = cold_start_aproximated_length(@user.ratings.length)
    else # ak mam dost ratingov
      prohibited_categories = @user.ratings.take((@all_categories.length * 0.1).floor).map { |rating| rating.joke.category } # ignorujem posledne hodntenych x ratingov (x = 10% kategorii)
      approximated_length = select_approximated_length # odhadovana dlzka vtipu
    end
    select_joke(variance, approximated_length, prohibited_categories) # nechcem kategoriu ktora naposledy bola
  end

  def cold_start_aproximated_length(number) # lengths got from data analysis
    number = number % 5
    case number
      when 0
        185
      when 1
        58
      when 2
        303
      when 3
        93
      else
        130
    end
  end

  def select_joke(variance, approximated_length, prohibited_categories = [])
    variance *= 2 if prohibited_categories.length > @all_categories.length * (0.3)
    prohibited_categories = [] if variance >= 0.5 # ak je vysoky variance chcem hladat vo vsetkych kategoriach
    category = select_category(prohibited_categories) # find category
    find_joke_in_category(category, approximated_length, variance) || # try to find suitable joke in category
        select_joke(variance, approximated_length, prohibited_categories.push(category)) # if we didnt find go recursive without this category
  end

  def select_approximated_length
    total_points = 0.0
    ratings = []
    @user.ratings.each do |rating|
      total_points += evaluate_rate(rating.user_rating)
      ratings.push([rating,total_points])
    end
    points = rand(total_points.floor)
    index = ratings.bsearch_index { |x| x[1] >= points }
    ratings[index][0].joke.content.length
  end

  def select_category(prohibited_categories = [])
    possible_categories = @all_categories - prohibited_categories # selects possible categories
    rated_categories = @user.user_prefer_categories.map { |upf| upf.category } # selects user rated categories
    # give every category change to get selected, amplify chances of above average user favourite categories
    total_points = 0.0
    evaluated_categories = []
    possible_categories.each do |category|
      category_position = rated_categories.find_index(category)
      if category_position
        rated_jokes_in_category = @user.user_prefer_categories[category_position].total_rated_jokes
        category_average = @user.user_prefer_categories[category_position].average_rate
        total_points += evaluate_rate(category_average) * (1 - category_penalization(category, rated_jokes_in_category))
      else
        total_points += evaluate_rate(user_category_average) * (1 - category_penalization(category, 0))
      end
      evaluated_categories.push([category, total_points]) # to add not rated categories
    end
    # simulates choosing category
    points = rand(total_points.floor)
    puts points
    index = evaluated_categories.bsearch_index { |x| x[1] >= points } # to simulate choosing with different priorities
    raise 'all jokes rated' if index == nil
    evaluated_categories[index][0]
  end

  def find_joke_in_category(category, approximated_length, variance)
    rated_jokes = @user.jokes.select { |joke| joke.category == category }
    all_jokes = category.jokes
    possible_jokes = all_jokes - rated_jokes
    puts category.name
    possible_jokes.sort! {|a,b| a.content.length <=> b.content.length}
    # approximated_length - approximated_length*variance <= joke.content.length <= approximated_length + approximated_length*variance
    start_index = possible_jokes.bsearch_index { |joke| joke.content.length >= approximated_length - approximated_length*variance }
    return nil if start_index == nil
    end_index = possible_jokes.bsearch_index { |joke| joke.content.length > approximated_length + approximated_length*variance } || possible_jokes.length
    end_index = end_index > start_index ? end_index - 1 : end_index
    index = rand(start_index..end_index)
    possible_jokes[index]
  end

  private
  def user_category_average
    return 1 if @user.user_prefer_categories.length == 0
    @user.user_prefer_categories.inject(0) { |sum, x| sum + x.average_rate } / @user.user_prefer_categories.length.to_f # calculate average rating of user rated categories
  end

  def evaluate_rate(rate) # quadratic function
    ((rate - user_category_average + 4) ** 5) / 8
  end

  def category_penalization(category, number_of_rated_jokes) # should be between 0 - 1
    total_jokes = category.jokes.length.to_f
    if number_of_rated_jokes / total_jokes < 0.7 # 50% are not penalized
      0
    elsif total_jokes - number_of_rated_jokes < 0.1 # if all jokes are rated return 0
      1
    else
      number_of_rated_jokes / total_jokes - 0.7 # linear penalization for those categories with jokes over 70% full (0-30%)
    end
  end

end