class AddCopeFieldsToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :questionnaire_on_cope_may, :string
    add_column :health_pros, :questionnaire_on_cope_may_time, :string
    add_column :health_pros, :questionnaire_on_cope_june, :string
    add_column :health_pros, :questionnaire_on_cope_june_time, :string
    add_column :health_pros, :questionnaire_on_cope_july, :string
    add_column :health_pros, :questionnaire_on_cope_july_authored, :string
  end
end