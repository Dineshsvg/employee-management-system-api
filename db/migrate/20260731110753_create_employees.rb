class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :designation
      t.decimal :salary
      t.references :department, null: true, foreign_key: true

      t.timestamps
    end
  end
end
