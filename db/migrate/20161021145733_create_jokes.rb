class CreateJokes < ActiveRecord::Migration[5.0]
  def change
    create_table :jokes do |t|
      t.text :content
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
