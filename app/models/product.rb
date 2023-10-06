class Product < ApplicationRecord
    validates :name, presence: true
    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories
    has_many :order_products, dependent: :destroy
    has_many :orders, through: :order_products
    belongs_to :user
    scope :available_from, -> {where("available >=  ?", Time.now).order("available asc")}

    has_one_attached :cover_image
    has_many_attached :gallery
end
