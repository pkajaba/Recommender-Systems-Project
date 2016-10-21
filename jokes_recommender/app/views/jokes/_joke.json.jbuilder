json.extract! joke, :id, :content, :category_id, :created_at, :updated_at
json.url joke_url(joke, format: :json)