class CategorySerializer
  include JSONAPI::Serializer
  attributes :name
  has_many :products
end
