# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ApiToken.delete_all
Product.delete_all
User.delete_all

3.times do
  user = User.create! email: Faker::Internet.email, password: 'locadex1234'
  user.api_tokens.create
  2.times do
    product = Product.create!(
      name: Faker::Commerce.product_name,
      price: rand(1.0..1000.0),
      user_id: user.id
    )
  end
end