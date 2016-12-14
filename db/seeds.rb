# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def joke_categories
  <<EOF
Otázky a odpovede
Manželské pochúťky
Sexuálne harašenie
CD-Rómovia
Zo života
V obchodoch
Morbídne
Zo školských lavíc
Mužské pokolenie
Ženské pokolenie
Zvieracia farma
Náboženský humor
Láska, bože láska
Blondína z Londýna
Počítačové šialenstvo
Ach tie babky
Alkoholické opojenie
Policajné inferno
Svokry
Cudzinci versus cudzinci
Na homosexuálnu nôtu
Páni a ich sluhovia
Politické pobavenie
EOF
end

def create_filtered_data(jokes_per_category)
  i = 0
  selected_categories = joke_categories.lines
  selected_categories.each do |category|
    category.chop!
  end
  allCategories = Category.all
  allCategories.each do |category|
    print category.name + ' '
    puts 'number of jokes: ' + category.jokes.length.to_s
    if (selected_categories.include?(category.name))
      jokes = category.jokes.to_ary
      jokes.sort_by! { |joke| joke.content.length }
      index = jokes.bsearch_index { |x| x.content.length > 500 }
      position = index ? index - 1 : jokes.length - 1 # position of joke nearest under content.length 500
      position = jokes_per_category if position < jokes_per_category
      step = position / jokes_per_category.to_f

      print 'position of first under : ' + position.to_s + ' '
      puts 'selected step to iterate: ' + step.to_s # so that i take jokes by length equally
      puts 'jokes length:'
      jokes_per_category.times do |index|
        joke = jokes[(index*step).floor]
        File.open("db/filtered_data/#{i}.txt", 'w') do |file|
          file.puts(joke.content)
          file.write(joke.category.name)
          print joke.content.length.to_s + ' '
          i += 1
        end
      end
      puts
      puts 'total_saved_jokes: ' + i.to_s
      puts
    end
    puts
  end
end

def store_jokes_to_db(index)
  i = 0
  path = case index
           when 0
             './db/filtered_data/*.txt'
           else
             './db/all_jokes_from_selected_categories_data/*.txt'
         end
  Dir.glob(path) do |rb_file|
    puts i += 1
    content = File.read(rb_file).lines
    category_name = content.pop
    Category.create(name: category_name)
    category = Category.find_by(name: category_name)
    joke_content = content.join
    Joke.create(content: joke_content, category_id: category.id)
  end
end

def analyze_data
  total_length = 0
  jokes = Joke.all.sort { |f, s| f.content.length <=> s.content.length }
  length_categories = [[], [], [], [], []]
  i = 0
  jokes.each do |joke|
    puts joke.content.length
    i += 1
    pos = (jokes.length - i) / (jokes.length / 5)
    puts pos
    #length_categories[pos] += 1
    category = length_categories[pos]
    category.push(joke)
    total_length += joke.content.length
  end
  average_length = total_length / jokes.length
  puts
  puts jokes.length
  puts average_length
  puts
  length_categories.each do |l|
    puts l.first.content.length
    puts l.last.content.length
  end
end

def evaluate_rate(rating, min, max)
  return 0 if rating - min < 0.1
  (rating-min) / (max-min)
end

def normalize_rating(rating, average)
  rating - average
end

def csv_jokes_length_in_categories
  CSV.open('../graphs/csv_jokes_length_in_categories.csv', 'wb') do |csv|
    Joke.all.each do |joke|
      csv << [joke.content.length, joke.category.name]
    end
  end
end

def csv_category_popularity
  CSV.open('csv_category_popularity.csv', 'wb') do |csv|
    categories = Category.all.map { |category| [category.id, [0, 0]] }
    categories = Hash[categories.map { |key, value| [key, value] }]
    user_all.each do |user|
      upcs = user.user_prefer_categories.select { |upc| upc.total_rated_jokes >= 2 }
      if upcs == []
        puts user.name
        next
      end
      upcs.sort! { |a, b| a.average_rate <=> b.average_rate }
      min = upcs.first.average_rate
      max = upcs.last.average_rate
      upcs.each do |upc|
        categories[upc.category.id][0] += evaluate_rate(upc.average_rate, min, max)
        categories[upc.category.id][1] += 1
      end
    end
    categories.each do |key, value|
      csv << [Category.find(key).name, (value[0]/value[1].to_f).to_s]
    end
  end
end

def csv_users_categories_normalized
  CSV.open('csv_categories_normalized_rating.csv', 'wb') do |csv|
    users = user_all.map { |user| user }
    users.sort! { |user| user.ratings.length }
    users.take(10).each do |user|
      categories = Category.all.map { |category| [category.id, [0, 0]] }
      categories = Hash[categories.map { |key, value| [key, value] }]
      upcs = user.user_prefer_categories.select { |upc| upc.total_rated_jokes >= 2 }
      if upcs == []
        puts user.name
        next
      end
      upcs.sort! { |a, b| a.average_rate <=> b.average_rate }
      min = upcs.first.average_rate
      max = upcs.last.average_rate
      upcs.each do |upc|
        categories[upc.category.id][0] += evaluate_rate(upc.average_rate, min, max)
        categories[upc.category.id][1] += 1
      end
      categories.each do |key, value|
        csv << [Category.find(key).name, (value[0]/value[1].to_f).to_s]
      end
    end
  end
end

def best_joke
  CSV.open('best_joke.csv', 'wb') do |csv|
    categories = Category.all.map { |category| [category.id, [0, 0]] }
    categories = Hash[categories.map { |key, value| [key, value] }]
    user_all.each do |user|
      upcs = user.ratings
      upcs.sort! { |a, b| a.average_rate <=> b.average_rate }
      min = upcs.first.average_rate
      max = upcs.last.average_rate
      upcs.each do |upc|
        categories[upc.category.id][0] += evaluate_rate(upc.average_rate, min, max)
        categories[upc.category.id][1] += 1
      end
    end
    categories.each do |key, value|
      puts Category.find(key).name + ',' + (value[0]/value[1].to_f).to_s
    end
  end
end

def users_similarities
  CSV.open('users_similarities.csv', 'wb') do |csv|
    users = user_all
    similarities = Hash.new
    users.each do |user|
      users.each do |otherUser|
        if similarities[[user.id, otherUser.id]] == nil && similarities[[otherUser.id, user.id]] == nil
          similarities[[user.id, otherUser.id]] = pearson(user, otherUser)
        end
      end
    end
    similarities.each_pair { |key, value| csv << [key,value] }
  end
end

def pearson(user, otherUser)
  common_jokes = user.jokes & otherUser.jokes
  n = common_jokes.length
  if n == 0
    return 0
  end

  other_user_ratings_raw = find_ratings(otherUser, common_jokes)
  user_ratings_raw = find_ratings(user, common_jokes)
  other_user_ratings = other_user_ratings_raw.uniq { |rating| rating.joke_id }
  user_ratings = user_ratings_raw.uniq { |rating| rating.joke_id }
  other_user_ratings = other_user_ratings.map { |rating| rating.user_rating }
  user_ratings = user_ratings.map { |rating| rating.user_rating }
  #should not happen but it happened :D
  if (user_ratings.length != other_user_ratings.length)
    return 0
  end

  numerator = user_ratings.zip(other_user_ratings).map { |i, j| (i- user.average)*(j-otherUser.average) }
                  .inject(0, :+)
  divider_user = other_user_ratings.map {
      |rating| (rating- otherUser.average)**2 }.inject(0, :+)
  divider_other = user_ratings.map {
      |rating| (rating- user.average)**2 }.inject(0, :+)

  divider = Math.sqrt(divider_user)*Math.sqrt(divider_other)

  if divider == 0
    return 0
  end
  numerator/divider
end

def find_ratings(user, jokes)
  Rating.where(:user_id => user.id).where(:joke_id => jokes)
end

def user_all
  User.all.select {|user| user.ratings.length > 10}
end

#MAIN
#create_filtered_data(20)
#save_some_csv
#analyze_data

#csv_category_popularity
users_similarities


