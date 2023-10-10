### Ricerca per i prodotti

Apriamo il modello `app/models/products.rb` e implementiamo il nostro motore di ricerca.

#### Ricerca per `name`

```ruby
class Product < ApplicationRecord
    validates :name, presence: true
    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories

    scope :available_from, -> {where("available >=  ?", Time.now).order("available asc")}

    has_one_attached :cover_image
    has_many_attached :gallery

    scope :filter_by_name, lambda { |keyword| where('lower(name) LIKE ?', "%#{keyword.downcase}%")}
}

end

```

#### Ricerca per `price`

```ruby
class Product < ApplicationRecord
    #...
    #...
    scope :filter_by_name, lambda { |keyword| where('lower(name) LIKE ?', "%#{keyword.downcase}%")}
    scope :above_or_equal_to_price, lambda { |price| where('price >= ?', price)}
}

end

```

curl -X GET -H "Content-Type: application/json" -d '{"product": {"name": "Marta"}}' localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"

curl -X GET localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"

curl -G  -d '{"product": {"name": "Marta"}}' localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"

curl 'localhost:3000/api/v1/products/?name=a' -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"

curl -G  -d "param1=value1" -d "param2=value2" localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"