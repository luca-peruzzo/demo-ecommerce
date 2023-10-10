class Order < ApplicationRecord
  #before_validation :set_total! 
  belongs_to :user
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  def set_total!
    self.total = products.sum :price
  end
end
