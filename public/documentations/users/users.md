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

Testiamo anche la risposta dal server con `cURL`:
```sh
curl -X GET http://localhost:3000/api/v1/users/1
```

Ed otteniamo come risposta:

```ruby
{"id":1,"name":"Antonino","email":"antoninoscaffidi@gmail.com","password_digest":"$2a$12$VvLmYtWxYl7.RuibB.4CP.03/PqNldv19bGKrVF.wGMTrhjgkLJm6","created_at":"2023-10-04T08:07:03.146Z","updated_at":"2023-10-04T08:07:03.146Z"}%

```

Perfetto funziona tutto!!!