* bundle add faker

bin/rails g migration add_user_id_to_products user:belongs_to

Apriamo: `db/seed.rb`

``` ruby
Product.delete_all
User.delete_all
3.times do
    user = User.create! email: Faker::Internet.email, password:
    'locadex1234'
    user.api_tokens.create
    puts "Created a new user: #{user.email}"

    2.times do
        product = Product.create!(
        name: Faker::Commerce.product_name,
        price: rand(1.0..100.0),
        user_id: user.id
        )
        puts "Created a brand new product: #{product.name}"
        end
end
```



rails generate serializer User email 

La serializzazione permetterà di convertire il nostro oggetto Utente in JSON, che implementa tutte le specifiche JSON:API. Perché abbiamo specificato.
Attribu come email, la recuperiamo nell'array di dati.

UserSerializer.new( User.first ).serializable_hash

Apriamo `app/controllers/api/v1/users_controller.rb`

```ruby
render json: UserSerializer.new(@user).serializable_hash.to_json
```


#serializer products

options = { include: [:user] }
render json: ProductSerializer.new(@product, options).serializable_hash.to_json


##serializer user
has_many :products
options = { include: [:products] }
render json: UserSerializer.new(@user, options).serializable_hash.to_json

##serializer
 #options = { include: [:products] }
#render json: UserSerializer.new(@user, options).serializable_hash.to_json
render json: UserSerializer.new(@user).serializable_hash.json


render json: ProductSerializer.new(@product).serializable_hash.to_json
    #options = { include: [:user] }
    #render json: ProductSerializer.new(@product, options).serializable_hash.to_json