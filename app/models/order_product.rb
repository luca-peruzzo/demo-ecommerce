class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product, inverse_of: :order_products
  
 
end
