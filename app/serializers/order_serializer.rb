class OrderSerializer
  include JSONAPI::Serializer
  attributes :total
  belongs_to :user
  has_many :products 
end
