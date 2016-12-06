class ContentBasedStrategy
  def initialize user
    @user = user
  end

  def recommend_next
    #TODO pada lebo user nema najprv ziadne hodnotenie a delim 0/0
    #TODO daky start umely vymysliet


    preferring_factor = 4 # ako velmi chceme aby vyberalo kategorie nad priemernym hodnotenim
    variance = 0.3 # ako daleko od odhadovanej dlzky budeme schvalovat
    puts 'a'
    approximated_length = select_approximated_length # odhadovana dlzka vtipu
    puts 'b'
    #TODO treba spravit ak uz ma nejake hodnotenie tak robim toto
    select_joke(preferring_factor, variance, approximated_length, [@user.ratings[0].joke.category]) # nechcem kategoriu ktora naposledy bola
  end

  #TODO myslim ze toto je naivne
  def select_approximated_length
    total = 0.0
    number = 0.0
    @user.ratings.each do |rating|
      total += rating.user_rating * rating.joke.content.length
      number += rating.user_rating
    end
    (total / number).floor
  end

  def select_joke(preferring_factor, variance, approximated_length, prohibited_categories = [])
    if prohibited_categories.length = Category.all.length # increase variance if we didnt find suitable joke in any category
      prohibited_categories = []
      variance *= 2
      return nil if variance >= 50 # ak odpovedal na pravdepodobne( mozno na extra dlhy neodpovedal) vsetky vtipy tak vratim nil
    end
    category = select_category(preferring_factor, prohibited_categories) # find category
    find_joke_in_category(category, approximated_length, variance)  || # try to find suitable joke in category
        select_joke(preferring_factor, variance, approximated_length, prohibited_categories.push(category)) # if we didnt find go recursive without this category
  end

  def select_category(preferring_factor = 1, prohibited_categories = [])
    possible_categories = Category.all - prohibited_categories # selects possible categories
    rated_categories = @user.user_prefer_categories.map { |upf| upf.category } # selects user rated categories
    user_average = @user.user_prefer_categories.inject(0) { |sum, x| sum + x.average_rate } / @user.user_prefer_categories.length.to_f # calculate average rating of user rated categories
    # give every category change to get selected, amplify chances of above average user favourite categories
    evaluated_points = 0.0
    evaluated_categories = []
    possible_categories.each do |category|
      pos = rated_categories.find_index(category)
      if pos
        category_average = @user.user_prefer_categories[pos].average_rate
        if category_average >= user_average
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
    # simulates choosing category
    points = rand(evaluated_points.floor)
    evaluated_categories.bsearch_index { |x| x[1] > points } # to simulate choosing with different priorities
  end

  def find_joke_in_category(category, approximated_length, variance)
    rated_jokes = @user.jokes.select { |joke| joke.category == category }
    all_jokes = category.jokes
    possible_jokes = all_jokes - rated_jokes
    index = possible_jokes.bsearch_index { |joke| approximated_length - approximated_length*variance <= joke.content.length <= approximated_length + approximated_length*variance }
    possible_jokes[index]
  end
end