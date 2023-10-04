class Category < ApplicationRecord
    has_many :product_categories
    has_many :products, through: :product_categories
    has_one_attached :cover_image
end
