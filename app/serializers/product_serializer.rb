class ProductSerializer
  include JSONAPI::Serializer
  attributes :name, :description
  has_many :categories
end
