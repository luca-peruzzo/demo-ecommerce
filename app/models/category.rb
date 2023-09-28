class Category < ApplicationRecord
    has_many :product_categories, depedent: :destroy
    has_many :products, through: :product_categories
end
