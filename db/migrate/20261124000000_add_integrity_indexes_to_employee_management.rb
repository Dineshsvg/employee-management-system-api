class AddIntegrityIndexesToEmployeeManagement < ActiveRecord::Migration[8.1]
  def change
    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_lower_email"
    add_index :employees, "LOWER(email)", unique: true, name: "index_employees_on_lower_email"
    add_index :departments, "LOWER(name)", unique: true, name: "index_departments_on_lower_name"
    add_index :employees, :designation
    add_index :employees, :created_at
  end
end
