class CreateFrequentlyAskedQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :frequently_asked_questions do |t|
      t.string :header
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
