unless Rails.env.test?
  admin = User.find_or_initialize_by(email: "admin@example.com")
  admin.name = "System Administrator"
  admin.role = "admin"

  if admin.new_record?
    admin.password = ENV.fetch("ADMIN_PASSWORD") do
      raise "Please set ADMIN_PASSWORD before running seeds"
    end
  end

  admin.save! if admin.new_record? || admin.changed?

  puts "Seeded administrator: admin@example.com"
end
