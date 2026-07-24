class CreateAiResults < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_results do |table|
      table.references :user, null: false, foreign_key: { on_delete: :restrict }
      table.string :feature, null: false
      table.json :input, null: false
      table.text :output, null: false
      table.string :model, null: false
      table.timestamps
    end
    add_index :ai_results, %i[user_id feature created_at]
  end
end
