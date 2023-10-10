class ProductSerializer
  include JSONAPI::Serializer
  attributes :name, :price
  belongs_to :user
  #has_many :categories
end
