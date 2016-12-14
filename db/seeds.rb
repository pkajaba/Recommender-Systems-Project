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
  #Rating.delete_all
  #Joke.delete_all
  #Category.delete_all

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
  max-min / rating-min
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
  #CSV.open('../graphs/csv_category_popularity.csv', 'wb') do |csv|
    categories = Category.all.map { |category| [category.id, [0, 0] ] }
    categories = Hash[categories.map {|key, value| [key, value]}]
    categories
    User.all.each do |user|
      upcs = user.user_prefer_categories.select {|upc| upc.total_rated_jokes >= 2}
      upcs.sort! {|a,b| a.average_rate <=> b.average_rate}
      min = upcs.first
      max = upcs.last
      upcs.each do |upc|
        categories[upc.category.id][0] += evaluate_rate(upc.average_rate, min, max) #TODO este premysliet
        categories[upc.category.id][1] += 1
      end
    end
    categories.each do |key, value|
      puts Category.find(key).name + ',' + (value[0]/value[1].to_f).to_s
    end
  #end
end

def csv_users_categories_normalized
  #CSV.open('../graphs/csv_categories_normalized_rating.csv', 'wb') do |csv|
    users = User.all.each.sort! {|user| user.ratings.length}
    users.take(10).each do |user|
      categories = Category.all.map { |category| [category.id, [0, 0] ] }
      categories = Hash[categories.map {|key, value| [key, value]}]
      upcs = user.user_prefer_categories.select {|upc| upc.total_rated_jokes >= 2}
      upcs.sort! {|a,b| a.average_rate <=> b.average_rate}
      min = upcs.first
      max = upcs.last
      upcs.each do |upc|
        categories[upc.category.id][0] += evaluate_rate(upc.average, min, max) #TODO este premysliet
        categories[upc.category.id][1] += 1
      end
      categories.each do |key, value|
        puts Category.find(key).name + ',' +(value[0]/value[1].to_f).to_s
      end
    end
  #end
end

#MAIN
#create_filtered_data(20)
#save_some_csv
#analyze_data
#store_jokes_to_db(0)


csv_category_popularity



