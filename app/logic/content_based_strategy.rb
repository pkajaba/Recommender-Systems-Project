class ContentBasedStrategy
  def initialize user
    @user = user
    @all_categories = Category.all
  end

  # Odporuci vtip na zaklade oblubenosti kategorii a dlzky vtipu
  def recommend_next
    variance = 0.1 # between 0 - inf +- kolko percent dlzky chceme hladat (1 = 100%)
    if @user.ratings.length < @all_categories.length / 5 # nazaciatku ziskam 1 rating pre 20% kategorii
      prohibited_categories = @user.ratings.map { |rating| rating.joke.category } # docielim ze na cold start kazda kategoria bude raz
      approximated_length = cold_start_aproximated_length(@user.ratings.length)
    else # ak mam dost ratingov
      prohibited_categories = categories_of_last_x_jokes(0.1) # ignorujem kategorie posledne hodntenych x vtipov (viac v categories_of_last_x_jokes)
      approximated_length = select_approximated_length
    end
    joke = select_joke(variance, approximated_length, prohibited_categories)
    {joke: joke, suggested_rating: suggest_rating(joke)}
  end

  # Pokusi sa vybrat vtip z povolenych kategorii
  # (prohibited_categories funguju pre ingorovanie urcitych kategorii -> napriklad kategorie posledne x hodnotenych vtipov
  #                                                                   -> napriklad kategoriu v ktorej nieje vtip urcitej dlzky +- variance
  def select_joke(variance, approximated_length, prohibited_categories = [])
    if prohibited_categories.length > @all_categories.length * (0.3) #zvysim variance ak v 30% prehladanych kategoriach som nenasiel vtip s urcitou dlzkou
      variance *= 2
      prohibited_categories = categories_of_last_x_jokes(0.1)
    end
    prohibited_categories = [] if variance >= 0.5 # ak je vysoky variance chcem hladat vo vsetkych kategoriach
    category = select_category(prohibited_categories) # zvolim hladanu kategoriu
    find_joke_in_category(category, approximated_length, variance) || # skusim najst vtip
        select_joke(variance, approximated_length, prohibited_categories.push(category)) # ak sa nepodari hladam dalej bez kategorie
  end

  # Dlzky ziskane analyzou dat, pomahaju na zaciatku aby som umonil uzivatelovi ohodnotit vtipy roznych dlzok
  # 0-20% najkratsich -> priemerna dlzka 58
  # 20-40% najkratsich -> priemerna dlzka 93
  # ...
  def cold_start_aproximated_length(number)
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

  # Odhadnute dlzky pre normalny beh algoritmu ked prekonam cold-start
  # kazdemu ohodnotenemu vtipu pridelim pocet bodov zavislych na jeho ratingu
  # zo vsetkych pridelenych bodov vylosujem nahodne cislo, najdem vtip ktory obsahuje toto cislo a vratim jeho dlzku
  # priklad:
  #   3 vtipy (dlzka,hodnotenie) - (20,1),(50,5),(100,3)
  #   evalaute_rate(1) -> 2, evalaute_rate(5) -> 162, evalaute_rate(3) -> 32,
  #   vtip s hodnotenim 1 bude mat interval <0-2> (sanca 1%), vtip s hodnotenim 5 (2,164> (sanca 82%), vtip s hodnotenim 3 (164, 196> (sanca 17%)
  def select_approximated_length
    total_points = 0.0
    ratings = []
    @user.ratings.each do |rating|
      total_points += evaluate_rate(rating.user_rating)
      ratings.push([rating,total_points])
    end
    points = rand(total_points.floor)
    index = ratings.bsearch_index { |x| x[1] >= points } #umozni najst spravny interval
    ratings[index][0].joke.content.length
  end

  # Analogicky ako select_approximated_length
  # naviac penalizuje kategorie ktore maju ohodntenych x% ( zavisi na impl. category_penalization) a viac vtipov
  # kazda possible kategoria dostane interval podla jej ratingu a naplnenia, nasledne nahodne vyberem cislo a hladam spravny interval
  def select_category(prohibited_categories = [])
    possible_categories = @all_categories - prohibited_categories # selects possible categories
    rated_categories = @user.user_prefer_categories.map { |upf| upf.category } # selects user rated categories
    total_points = 0.0
    evaluated_categories = []
    possible_categories.each do |category|
      category_position = rated_categories.find_index(category)
      if category_position # pre tie ktore maju ohodnoteny aspon jeden vtip
        rated_jokes_in_category = @user.user_prefer_categories[category_position].total_rated_jokes
        category_average = @user.user_prefer_categories[category_position].average_rate
        total_points += evaluate_rate(category_average) * (1 - category_penalization(category, rated_jokes_in_category))
      else # pre este nehodnotene kategorie
        total_points += evaluate_rate(@user.average) * (1 - category_penalization(category, 0))
      end
      evaluated_categories.push([category, total_points])
    end
    # simulates choosing category
    points = rand(total_points.floor)
    puts points
    index = evaluated_categories.bsearch_index { |x| x[1] >= points } # najde spravny interval
    raise 'all jokes rated' if index == nil
    evaluated_categories[index][0]
  end

  # Pokusi sa najst vtip v danej kategorii s urcenou dlzkou +- x% (zavisi od variance)
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

  def suggest_rating(joke)
    #TODO:
  end

  private
  # vrati body podla hodnotenia -> umozni preferovanie vyssie hodnotenych vtipov/kategorii
  # evaluate_rate(1) average 3 -> 2, evaluate_rate(2) average 3 -> 10, evaluate_rate(3) average 3 -> 32, evaluate_rate(4) average 3 -> 78, evaluate_rate(5) average 3 -> 162
  # evaluate_rate(1) average 4 -> 0.x, evaluate_rate(3) average 4 -> 10, evaluate_rate(5) average 4 -> 78
  def evaluate_rate(rate) # ovplyvnuje sancu s akou sa dostane do vyberu
    ((rate - @user.average + 4) ** 4) / 8
  end

  # vrati kategorie poslednych x vtipov, x vyratam ako variance * pocet kategorii (variance = kolko percent)
  def categories_of_last_x_jokes(variance)
    @user.ratings.take((@all_categories.length * variance).floor).map { |rating| rating.joke.category }
  end

  # snazim sa linearne penalizovat kategorie ktore su naplnene nad 70%
  def category_penalization(category, number_of_rated_jokes) # should be between 0 - 1
    total_jokes = category.jokes.length.to_f
    if number_of_rated_jokes / total_jokes > 0.99 # ako som ohodnotil vsetky vtipy 1
      1
    elsif number_of_rated_jokes / total_jokes < 0.7 # ak z kategorie mam menej ako 70% ohodnotenich vtipov tak nepenalizujem
      0
    else
      number_of_rated_jokes / total_jokes - 0.7 # penalizujem 0-30% kategoriu s naplnenim nad 70%
    end
  end

end