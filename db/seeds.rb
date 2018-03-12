# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def seed_production
  # Ran for both production and developement environments
  Registry.where(name: "SUSE").find_or_initialize.tap do |r|
    r.url = "https://registry.suse.com"
    r.save
  end
end

def seed_development
  # Ran after seed_production, only on development and test
  # environments
  # nothing yet
end

if ["production", "development"].include? Rails.env
  seed_production
end

if ["development", "test"].include? Rails.env
  seed_development
end
