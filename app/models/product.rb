class Product < ApplicationRecord
    validates :name, presence: true
    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories

    scope :available_from, -> {where("available >=  ?", Time.now).order("available asc")}

    has_one_attached :cover_image
    has_many_attached :gallery
end
