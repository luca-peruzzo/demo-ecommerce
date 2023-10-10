class ProductSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :available
  belongs_to :user
  #has_many :categories
end
