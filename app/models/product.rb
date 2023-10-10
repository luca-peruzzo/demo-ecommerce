class Product < ApplicationRecord
    validates :name, presence: true
    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories
    belongs_to :user

    scope :available_from, -> {where("available >=  ?", Time.now).order("available asc")}

    has_one_attached :cover_image
    has_many_attached :gallery

    scope :filter_by_name, lambda { |keyword| where('lower(name) LIKE ?', "%#{keyword.downcase}%")}

    #scope :recent, lambda {order(:updated_at)}

    scope :above_or_equal_to_price, lambda { |price| where('price >= ?', price) }

    scope :below_or_equal_to_price, lambda { |price| where('price <= ?', price)}


    def self.search(params = {})
        products = params[:product_ids].present? ? Product.where(id: params[:product_ids]) : Product.all
        
        products = products.filter_by_name(params[:keyword]) if params[:keyword]

        products = products.above_or_equal_to_price(params[:min_price].to_f) if params[:min_price]

        products = products.below_or_equal_to_price(params[:max_price].to_f) if params[:max_price]

        products = products.recent if params[:recent]

        products
    end




end
