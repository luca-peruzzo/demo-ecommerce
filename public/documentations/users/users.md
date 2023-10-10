### Gestione degli utenti

Iniziamo con il namespace per la gestione degli  `utenti` dalla nostra API.

```sh
bin/rails generate controller api::v1::users 
```

Questo comando creerà un file `users_controller_test.rb`.

Quello che vogliamo testare per un API è:
* La struttura JSON restituita dal server.
* Il rcodice di risposta HTTP restituito dal server.

Iniziamo con il test. Apriamo il file `test/controllers/api/v1/users_controller_test.rb`

```ruby
require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should show user" do
    get api_v1_user_url(@user), as: :json
    assert_response :success
    json_response = JSON.parse(self.response.body)
    assert_equal @user.email, json_response['email']  
  end
end

```

Poi aggiungiamo al controller `app/controllers/api/v1/users_controller.rb` l'azione `show`:

```ruby
class Api::V1::UsersController < ApplicationController
    def show
        render json: User.find(params[:id])
    end
end
```

Ed esguiamo il test:

```sh
rails test
```

Otteniamo il seguente messaggio:
```sh 
# Running:

E

Error:
Api::V1::UsersControllerTest#test_should_show_user:
NoMethodError: undefined method `api_v1_user_url' for #<Api::V1::UsersControllerTest:0x000000010e520a80>
    test/controllers/api/v1/users_controller_test.rb:9:in `block in <class:UsersControllerTest>'


rails test test/controllers/api/v1/users_controller_test.rb:8

..
```
Questo errore ci indica, che bisogna inserire nel file `config/routes` la risorsa `:users`. Quindi avremo: 
`config/routes.rb`

```ruby 
Rails.application.routes.draw do 
    #...

    namespace :api, defaults: { format: :json } do
        namespace :v1 do
        #...
        #...
        resources :users, only: [:show]
        
        end
    end

end

```

Esgeguiamo nuovamente il comando:

```sh
bin/rails test
```

Ed avremo come risultato:
```sh
# Running:

...
3 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

Ok! Abbiamo passato il test!!!

Testiamo la nostra risorsa con `cURL`:
```sh
curl -X GET http://localhost:3000/api/v1/users/1
```

Ed otteniamo come risposta:

```ruby
{"id":1,"name":"Antonino","email":"antoninoscaffidi@gmail.com","password_digest":"$2a$12$VvLmYtWxYl7.RuibB.4CP.03/PqNldv19bGKrVF.wGMTrhjgkLJm6","created_at":"2023-10-04T08:07:03.146Z","updated_at":"2023-10-04T08:07:03.146Z"}%

```

Perfetto funziona tutto!!!


### Creazione degli utenti

Iniziamo con il test. Apriamo il file `test/controllers/api/v1/users_controller_test.rb`, e testiamo la creazione di un nuovo utente:

```ruby
require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
    #...  
    #...
    test "should create  user" do
        assert_difference('User.count') do
            post api_v1_users_url, params: {user: {name: 'Antonino', email: 'test@test.com', password: '123456' }}, as: :json
        end
        assert_response :created
    end

    test "should not create user with taken email" do
        assert_no_difference('User.count') do
        post api_v1_users_url, params: { user: { email: @user.email, password: '12345678' } }, as: :json
    end
        assert_response :unprocessable_entity
    end

    #...
end
```
Nel primo test verfichiamo la creazione di un utente valido, tramite una richiesta POST. 
Poi verifichiamo che esiste un utente in più nel database tramite `assert_no_difference('User.count')` ed infine che venga creato il codice 201 come risposta HTTP

Eseguiamo il test:

```sh
rails test
```

Il test torna un errore: manca l'action `create` nel file `app/controllers/api/v1/users_controllers.rb`:

```ruby
class Api::V1::UsersController < ApplicationController
    def show
        render json: User.find(params[:id]) 
    end

    def create
        @user = User.new(user_params)

        if @user.save
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end

    end

    private
    
    def user_params
        params.require(:user).permit(:name, :email, :password)
    end

end
```

Andiamo avanti e inseriamo le action `updated` e `destroy`, addesso il nostro controller `app/controllers/api/v1/users_controller.rb` è completo:


``` ruby 
class Api::V1::UsersController < ApplicationController
    before_action :set_user, only: %i[show update destroy]

    def index
        @users = User.all
        render json: @users
    end
    
    def show
        render json: @user
    end

    def create
        @user = User.new(user_params)

        if @user.save
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end

    end

    # PATCH/PUT /users/1
    def update
        if @user.update(user_params)
            render json: @user, status: :ok
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end


    # DELETE /users/1
    def destroy
        @user.destroy
        head 204
    end


    private

    def set_user
        @user = User.find(params[:id])
    end
    
    def user_params
        params.require(:user).permit(:name, :email, :password)
    end

end


```

Come si può vedere abbiamo impost anche il metodo `set_user`.

Ricordiamoci sempre di inserire gli instradamenti nel file `config/routes`:

```ruby
Rails.application.routes.draw do 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "store#index"

  resources :companies do 
    resources :social_networks
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get "home/index", to: "home#index"
      resources :users, only: [:show, :create, :update, :destroy]
      resources :products, only: [:index, :show, :create, :update, :destroy]
     
    end
  end

end

```

### Testiamo con `cURL`

#### GET `user`
```ruby
curl -X GET "localhost:3000/api/v1/users/1"  -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"

```

#### CREATE `user`

``` ruby
curl -X POST -H "Content-Type: application/json" -d '{"user": {"name": "Marta", "email": "marta@amvidealab.com", "password": "12345678", "password_confirmation": "12345678"}}' localhost:3000/api/v1/users.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

#### UPDATE `user`
``` ruby
curl -X PATCH -H "Content-Type: application/json" -d '{"user": {"name": "Marta EDIT"}}' localhost:3000/api/v1/users/2.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

#### DESTROY `user`

``` ruby
curl -X DELETE   localhost:3000/api/v1/users/2.json -H "Authorization: Bearer 8c9b3f81c79e9d0d463677458f7c3660"
```

Perfetto. Funziona tutto!!!
