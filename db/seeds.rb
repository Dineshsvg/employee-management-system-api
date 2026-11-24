admin = User.find_or_initialize_by(email: "admin@example.com")
admin.name = "System Administrator"
admin.role = "admin"
admin.password = "ChangeMe123!" if admin.new_record?
admin.save! if admin.new_record? || admin.changed?

puts "Seeded administrator: admin@example.com (change the sample password before deployment)"
