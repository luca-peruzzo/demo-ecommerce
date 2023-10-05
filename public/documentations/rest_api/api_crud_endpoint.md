### API CRUD endpoint

Adesso  creiamo[Create], leggiamo[Read], aggiorniamo[Update] ed eliminiamo[Delete] una risorsa dalla nostra API.

Utilizziamo la risorsa `products`.

Prima di tutto inseriamo la nostra risorsa namespace API::V1 nel file `config/routes`

``` ruby
Rails.application.routes.draw do 
  #...

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      #...
      resources :products, only: [:index, :show, :create, :update, :destroy]
      #...
    end
  end

end
```

Adesso se esguiamo il comando:

```ruby
bin/rails routes -c api/v1/products
```
Possiamo vedere che la nostra risorsa `products` ha tutti gli instradamenti necesseri:

```ruby
 Prefix Verb   URI Pattern                    Controller#Action
api_v1_products GET    /api/v1/products(.:format)     api/v1/products#index {:format=>:json}
                POST   /api/v1/products(.:format)     api/v1/products#create {:format=>:json}
 api_v1_product GET    /api/v1/products/:id(.:format) api/v1/products#show {:format=>:json}
                PATCH  /api/v1/products/:id(.:format) api/v1/products#update {:format=>:json}
                PUT    /api/v1/products/:id(.:format) api/v1/products#update {:format=>:json}
                DELETE /api/v1/products/:id(.:format) api/v1/products#destroy {:format=>:json}

```

Aprimao il controller `app/controllers/api/v1/products_controller.rb`:

```ruby 

class Api::V1::ProductsController < ActionController::Base
  def index
    @products = Product.all
    render json: @products
  end

  def show 
    @product = Product.find(params[:id])
    render json: @product
  end

end
```

Il controller `products` deve ereditare dal controller `app/controllers/api/v1/authenticated_controller.rb`, in modo da usufrire dell'autenticazione e di tutti i metodi e variabili definiti in esso. Avremo quindi:

```ruby 

class Api::V1::ProductsController < Api::V1::AuthenticatedController
  def index
    @products = Product.all
    render json: @products
  end

  def show 
    @product = Product.find(params[:id])
    render json: @product
  end

end
```

In questo controller sono definite solamente le azioni `index` e `show`, per poter inserire, modificare ed eliminare un `prodotto` dobbiamo andare ad implementate i metodi: [`create`, `update` e `destroy`]


``` ruby 
class Api::V1::ProductsController < Api::V1::AuthenticatedController
  def index
    @products = Product.all
    render json: @products
  end

  def show 
    @product = Product.find(params[:id])
    render json: @product
  end

  def create
  end

  def update
  end

  def destroy
  end
end
```


Ok, testiamo con `cURL`, la nostra risorsa API:

Visualizziamo tutti i prodotti:

```ruby 
curl -X GET "localhost:3000/api/v1/products"  -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Visualizziamo un singolo prodotto:

```ruby 
curl -X GET "localhost:3000/api/v1/products/1.json"  -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Nel caso in cui il prodotto non sia trovato, riceviamo il seguente messaggio di errore:

```sh
ActiveRecord::RecordNotFound (Couldn't find Product with 'id'=1):
```

Quindi andiamo a gestire queste sitiazione aggiungen nel controller `app/controllers/api/v1/authenticaded_controller.rb` la seguente istruzione:

``` ruby 
class Api::V1::AuthenticatedController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    before_action :authenticate
    #...
    #...

end 
```

Quindi andiamo a definire il mentodo `handle_not_found`

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    before_action :authenticate
    attr_reader :current_api_token, :current_user

    def authenticate
        authenticate_user_with_token || handle_bad_authentication
    end


    private
    def authenticate_user_with_token
        authenticate_with_http_token do |token, options|
            @current_api_token = ApiToken.where(active: true).find_by(token: token)
            @current_user = @current_api_token&.user
            #debugger

        end
    end

    def handle_bad_authentication
        render json: {message: "Bad credentials"}, status: :unauthorized
    end

    def handle_not_found
        render json: {message: "Record not found"}, status: :not_found
    end

end

```


Adesso passiamo alla creazione di un prodotto tramite API:

``` ruby
curl -X POST -H "Content-Type: application/json" -d '{"product": {"name": "T-shirt", "description": "Example description", "price": "12.9"}}' localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Eseguendo il comando, otteniamo un errore che ci indica che manca l'azione `create`. Andiamo a definirla nel nostro controller `app/controllers/api/v1/products_controller.rb`


```ruby
class Api::V1::ProductsController < Api::V1::AuthenticatedController
  def index
    @products = Product.all
    render json: @products
  end

  def show 
    @product = Product.find(params[:id])
    render json: @product
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors }, status: :unprocessable_entity
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price)
  end

end

```

Se mandiamo in esecuzone nuovamente:

``` ruby
curl -X POST -H "Content-Type: application/json" -d '{"product": {"name": "T-shirt", "description": "Example description", "price": "12.9"}}' localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

In questo caso, ci viene ritornato il seguente messaggio:

```sh
ActionController::InvalidAuthenticityToken (Can't verify CSRF token authenticity.)
```
Per evitare questo errore nelle azioni (`Create`, `Update` e `Destroy`), bisonogna andare ad aggiungere nel controller `authenticated`,
la seguente istruzione:

```ruby
protect_from_forgery with: :null_session

```


Quindi il controller `app/controllers/api/v1/authenticated_controller.rb` sarà aggiornato nel seguente modo:

```ruby
class Api::V1::AuthenticatedController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    protect_from_forgery with: :null_session

    before_action :authenticate
    attr_reader :current_api_token, :current_user

    def authenticate
        authenticate_user_with_token || handle_bad_authentication
    end


    private
    def authenticate_user_with_token
        authenticate_with_http_token do |token, options|
            @current_api_token = ApiToken.where(active: true).find_by(token: token)
            @current_user = @current_api_token&.user
            #debugger

        end
    end

    def handle_bad_authentication
        render json: {message: "Bad credentials"}, status: :unauthorized
    end

    def handle_not_found
        render json: {message: "Record not found"}, status: :not_found
    end
end
```

Mandiamo nuovamente in esecuzione:

``` ruby
curl -X POST -H "Content-Type: application/json" -d '{"product": {"name": "T-shirt", "description": "Example description", "price": "12.9"}}' localhost:3000/api/v1/products.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Il nostro prodotto è stato creato!

Andiamo avanti con le azioni. Passiamo all'aggiornamento di un prodotto. Aggiungiamo al nostro controller `app/controllers/api/v1/products_controller.rb` l' azione  `update`

``` ruby
class Api::V1::ProductsController < Api::V1::AuthenticatedController
  #...


 def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price)
  end

end

```




Esguiamo da terminale:

``` ruby
curl -X PATCH -H "Content-Type: application/json" -d '{"product": {"name": "T-shirt edit", "description": "Example description", "price": "14.9"}}' localhost:3000/api/v1/products/2.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Perfetto il nostro metodo funziona correttamete!


Eliminiamo un prodotto:

Aggiungiamo al nostro controller `app/controllers/api/v1/products_controller.rb` l' azione  `destroy`

``` ruby
class Api::V1::ProductsController < Api::V1::AuthenticatedController
    #...
    #...

    def destroy
        @product = Product.find(params[:id])
        @product.destroy
        head 204
    end

    private
    def product_params
        params.require(:product).permit(:name, :description, :price)
    end
end

```

Esguiamo da terminale:

``` ruby
curl -X DELETE   localhost:3000/api/v1/products/2.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```