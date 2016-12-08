class ContentBasedStrategy
  def initialize user
    @user = user
    @all_categories = Category.all
  end

  def user_category_average
    @user.user_prefer_categories.inject(0) { |sum, x| sum + x.average_rate } / @user.user_prefer_categories.length.to_f # calculate average rating of user rated categories
  end

  def evaluate_rate(rate) # quadratic function
    ((rate - user_category_average + 5) ** 2) * 2
  end

  def category_incompletness(category, number_of_rated_jokes) # should be between 0 - 1
    total_jokes = category.jokes.length.to_f
    if number_of_rated_jokes / total_jokes < 0.5
      1
    elsif total_jokes - number_of_rated_jokes < 0.1
      0
    else
      #TODO
      1 - number_of_rated_jokes.to_f / total_jokes.to_f * 0.5
    end
  end

  def recommend_next
    category_preferring_factor = 1 # ako velmi chceme aby vyberalo kategorie nad priemernym hodnotenim
    variance = 0.2 # ako daleko od odhadovanej dlzky budeme schvalovat
    approximated_length
    prohibited_categories
    if @user.ratings.length < @all_categories.length / 5 # nazaciatku ziskam 1 rating pre 20% kategorii
      prohibited_categories = @user.ratings.map { |rating| rating.joke.category } # docielim ze na cold start kazda kategoria bude raz
      approximated_length = cold_start_aproximated_length(@user.ratings.length)
    else # ak mam dost ratingov
      prohibited_categories = @user.ratings.take(@all_categories.length / 7).map { |rating| rating.joke.category } # ignorujem posledne hodntenych x ratingov (x = 14% kategorii)
      approximated_length = select_approximated_length # odhadovana dlzka vtipu
    end
    select_joke(category_preferring_factor, variance, approximated_length, prohibited_categories) # nechcem kategoriu ktora naposledy bola
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

  def select_approximated_length
    #TODO
    total = 0.0
    number = 0.0
    @user.ratings.each do |rating|
      if rating >= user_average
        total += rating.user_rating * rating.user_rating * rating.joke.content.length
        number += rating.user_rating * rating.user_rating
      end
    end
    (total / number).floor
  end

  def select_joke(preferring_factor, variance, approximated_length, prohibited_categories = [])
    if prohibited_categories.length > @all_categories.length/3 # increase variance if we didnt find suitable joke in 33% of categories
      prohibited_categories = []
      variance *= 2
      return nil if variance >= 50 # ak odpovedal na pravdepodobne vsetky vtipy tak vratim nil
    end
    category = select_category(preferring_factor, prohibited_categories) # find category
    find_joke_in_category(category, approximated_length, variance) || # try to find suitable joke in category
        select_joke(preferring_factor, variance, approximated_length, prohibited_categories.push(category)) # if we didnt find go recursive without this category
  end

  def select_category(preferring_factor = 1, prohibited_categories = [])
    possible_categories = @all_categories - prohibited_categories # selects possible categories
    rated_categories = @user.user_prefer_categories.map { |upf| upf.category } # selects user rated categories
    # give every category change to get selected, amplify chances of above average user favourite categories
    evaluated_points = 0.0
    evaluated_categories = []
    possible_categories.each do |category|
      pos = rated_categories.find_index(category)
      if pos
        rated_jokes_in_category = @user.user_prefer_categories[pos].categories.length
        category_average = @user.user_prefer_categories[pos].average_rate
        evaluated_points += evaluate_rate(category_average)  * category_incompletness_percentage(category, rated_jokes_in_category) * preferring_factor
      else
        evaluated_points += evaluate_rate(user_category_average)  * category_incompletness_percentage(category,0) * preferring_factor
      end
      evaluated_categories.push([category, evaluated_points]) # to add not rated categories
    end
    # simulates choosing category
    evaluated_points.floor
    return nil if evaluated_points == 0
    points = rand(evaluated_points)
    evaluated_categories.bsearch_index { |x| x[1] > points } # to simulate choosing with different priorities
  end

  def find_joke_in_category(category, approximated_length, variance)
    a = variance
    x = approximated_length
    rated_jokes = @user.jokes.select { |joke| joke.category == category }
    all_jokes = category.jokes
    possible_jokes = all_jokes - rated_jokes
    #index = possible_jokes.bsearch_index { |joke| approximated_length - approximated_length*variance <= joke.content.length <= approximated_length + approximated_length*variance }
    index = possible_jokes.bsearch_index { |joke| (1/a - 1)/2 - joke.content.length/(2*a*x) } # ak toto pojde tak iny vtip :D
    #TODO testovat ci funguje
    possible_jokes[index]
  end
end