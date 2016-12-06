class CreateUserPreferCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :user_prefer_categories do |t|
      t.references :category, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :total_rated_jokes, default: 0
      t.integer :total_rate, default: 0
      t.timestamps
    end
  end
end
