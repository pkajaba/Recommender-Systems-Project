# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.delete_all
Joke.delete_all

i = 0
Dir.glob('./db/seed_data/*.txt') do |rb_file|
  puts i += 1
  content = File.read(rb_file).lines
  category_name = content.pop
  Category.create(name: category_name)
  category = Category.find_by(name: category_name)
  joke_content = content.join
  Joke.create(content: joke_content, category_id: category.id)
end