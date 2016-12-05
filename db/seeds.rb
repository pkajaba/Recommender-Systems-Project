# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

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

# Rating.delete_all
# Joke.delete_all
# Category.delete_all
#
# i = 0
# Dir.glob('./db/all_jokes_from_selected_categories_data/*.txt') do |rb_file|
# #Dir.glob('./db/filtered_data/*.txt') do |rb_file|
#   puts i += 1
#   content = File.read(rb_file).lines
#   category_name = content.pop
#   Category.create(name: category_name)
#   category = Category.find_by(name: category_name)
#   joke_content = content.join
#   Joke.create(content: joke_content, category_id: category.id)
# end

i = 0
selected_categories = joke_categories.lines
selected_categories.each do |category|
  category.chop!
end
allCategories = Category.all
allCategories.each do |category|
  print category.name + ' '
  puts 'number of jokes' + category.jokes.length.to_s + 'their content length'
  if (selected_categories.include?(category.name))
    jokes = category.jokes.to_ary
    jokes.sort_by! { |joke| joke.content.length }

    # find joke nearest under content.length 400 while there has to be at least 20 elements chosen
    positon = # position of joke nearest under content.length 500
    #iterate from 20th element and find nearest content.length 500

    puts step = (position / 20).floor # so that i take jokes by length equally
    jokes.take(20, step).each do |joke|
      File.open("db/filtered_data/#{i}.txt", 'w') do |file|
        file.puts(joke.content)
        file.write(joke.category.name)
        print joke.content.length.to_s + ' '
        i += 1
      end
    end


    # jokes.take(10).each do |joke|
    #   File.open("db/filtered_data/#{i}.txt", 'w') do |file|
    #     file.puts(joke.content)
    #     file.write(joke.category.name)
    #     print joke.content.length.to_s + ' '
    #     i += 1
    #   end
    # end
    # jokes.last(10).each do |joke|
    #   File.open("db/filtered_data/#{i}.txt", 'w') do |file|
    #     file.puts(joke.content)
    #     file.write(joke.category.name)
    #     print joke.content.length.to_s + ' '
    #     i += 1
    #   end
    # end


  end
  puts
end





