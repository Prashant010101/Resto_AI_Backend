class CreateChatbotLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :chatbot_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.text :message
      t.string :sender
      t.string :session_id

      t.timestamps
    end
  end
end
