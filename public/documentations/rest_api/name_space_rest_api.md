## DEMO EOMMERCE - REST API

![Corso Ruby On Rails](/public/documentations/rest_api/corso_ruby_on_rails_rest_api_schema_db.png "REST API")


Apriamo il file `config/routes.rb`

```ruby
Rails.application.routes.draw do 
#...
#...
namespace :api, defaults: { format: :json } do
    namespace :v1 do
        get "home/index", to: "home#index"
        #...
        #...
        #...
    end
end
```

Creazione del controller `app/controllers/api/v1home_controller.rb`

```ruby
class Api::V1::HomeController < ActionController::Base
    def index
        render json: {message: "Hello API world!"}
    end
end
```

Testiamo dal terminale il namespace e il controller appena creato con in comando `curl`
```sh
curl -X GET "localhost:3000/api/v1/home/index"
```

Aggiungiamo l'autentnticazione. Da terminale lanciamo il comando `rails` per generare un nuovo modello ApiToken, che ci servirà per gestire l'autenticazione delle nostre API:
```sh
rails generate model ApiToken token:text active:boolean user:references
```

Apriamo la migrazione appena creata:
```ruby
class CreateApiTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :api_tokens do |t|
      t.text :token
      t.boolean :active
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

e la modifichiamo nel seguente modo:
```ruby
class CreateApiTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :api_tokens do |t|
      t.text :token, null: false
      t.boolean :active, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```
e lanciamo la nostra migrazione:

```sh
bin/rails db:migrate
```

Adesso andiamo a modificare il modello `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  has_secure_password
  #...
  #...
  has_many :api_tokens

end
```

Apriamo il modello `app/models/api_token.rb` e aggiundiamo le seguenti istruzioni:
```ruby
class ApiToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true, uniqueness: true
  before_validation :generate_token, on: :create 
  #per consentire l'esecuzione di query sui dati crittografati
  encrypts :token, deterministic: true
  #Si consiglia l'approccio non deterministico a meno che non sia necessario eseguire query sui dati.
  
  private
  def generate_token
    self.token = Digest::MD5.hexdigest(SecureRandom.hex)
  end
end
```
Per far funzionare encryption abbiamo bisogno di  aggiungere encription secrets

```
bin/rails db:encryption:init
```

Questo comando genererà alcune righe a cui dovresti aggiungere `credentials.yml``:

```
active_record_encryption:
  primary_key: 0QlqC5JSxwlUi7cFn5uHmxhb65kqrJmm
  deterministic_key: n1rsktZhb9J1WU0qKqUpIPLim7JuxFgx
  key_derivation_salt: HOreQgTQ0tmh7NPbyRR9mUzzu2RTaXLO
```

``` sh
EDITOR='code  --wait' rails credentials:edit
```

Ok! Abbiamo aggioarnato il nostro file `credentials.yml`

Adesso apriamo la console:
```
bin/rails c
```
E aggiangiamo un token ad un utente:
```sh
user = User.first

User Load (0.6ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT $1  [["LIMIT", 1]]
=>
#<User:0x000000010e874380
 id: 3,
 name: "Antonino",
 email: "antoninoscaffidi@gmail.com",
 password_digest: "[FILTERED]",
 created_at: Wed, 04 Oct 2023 02:04:00.398186000 UTC +00:00,
 updated_at: Wed, 04 Oct 2023 02:04:00.398186000 UTC +00:00>

user.api_tokens

  ApiToken Load (9.7ms)  SELECT "api_tokens".* FROM "api_tokens" WHERE "api_tokens"."user_id" = $1  [["user_id", 3]]
=> []

```

Il nostro untente non ha nessun token, quindi ne creaimo uno:

```sh
user.api_tokens.create

  TRANSACTION (0.2ms)  BEGIN
  ApiToken Exists? (0.8ms)  SELECT 1 AS one FROM "api_tokens" WHERE "api_tokens"."token" = $1 LIMIT $2  [["token", "[FILTERED]"], ["LIMIT", 1]]
  ApiToken Create (33.5ms)  INSERT INTO "api_tokens" ("token", "active", "user_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["token", "[FILTERED]"], ["active", true], ["user_id", 3], ["created_at", "2023-10-04 02:10:42.694090"], ["updated_at", "2023-10-04 02:10:42.694090"]]
  TRANSACTION (2.3ms)  COMMIT

=>
#<ApiToken:0x000000010c6ed040
 id: 1,
 token: "[FILTERED]",
 active: true,
 user_id: 3,
 created_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00,
 updated_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00>

```
Quindi verifchiamo la presenza del token appena creato, associato al nostro utente.

```ruby
user.api_tokens.first
=>
#<ApiToken:0x000000010c6ed040
 id: 1,
 token: "[FILTERED]",
 active: true,
 user_id: 3,
 created_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00,
 updated_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00>
```

E per ottenere il `token`:
``` ruby
user.api_tokens.first.token
=> "ae7f32f8316e8cda1c44a98d233cdfc7"
```

Adesso, avendo un token possiamo trovare l'utente associato(grazie all'istruzione deterministic: true):

``` ruby
ApiToken.find_by(token: "ae7f32f8316e8cda1c44a98d233cdfc7")
  ApiToken Load (0.6ms)  SELECT "api_tokens".* FROM "api_tokens" WHERE "api_tokens"."token" = $1 LIMIT $2  [["token", "[FILTERED]"], ["LIMIT", 1]]
=>
#<ApiToken:0x000000010b2bd0c0
 id: 1,
 token: "[FILTERED]",
 active: true,
 user_id: 3,
 created_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00,
 updated_at: Wed, 04 Oct 2023 02:10:42.694090000 UTC +00:00>

```

Abbiamo concluso il nostro lavoro sui modelli.

Adesso dommiamo aggiungere l'autenticazione alla nostra api!
Aggiungiamo il file `app/controllers/api/v1/authenticated_controller.rb`

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
end 
```

Modifichiamo il controller `app/controllers/home_controller.rb`, in questo modo:

``` ruby
class Api::V1::HomeController < Api::V1::AuthenticatedController
    def index
        render json: {message: "Hello API world!"}
    end
end

```

Adesso testiamo la nostra `API`:
```sh
curl -X GET "localhost:3000/api/v1/home/index" 
```

Aggiungiamo il metodo authenticate al nostro `app/controllers/api/v1/authenticated_controller.rb`

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
    before_action :authenticate

    def authenticate
        authenticate_user_with_token || handle_bad_authentication
    end

    private

    def authenticate_user_with_token
        authenticate_with_http_token do |token, options|
            debugger
            token
        end 
    end

    def handle_bad_authentication
    end
end  
```

Adesso, lamciamo nuovamente il la nostra `GET`:
```sh
curl -X GET "localhost:3000/api/v1/home/index" 
```

Gestioamo un richiesta senza credenziali:

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
    #...
    #...

    def handle_bad_authentication
        render json: {message: "Bad credentials!"}, status: :unauthorized
    end
end 
```

E riceviamo, il seguente messaggio:
` {"message":"Bad credentials!"}% `
``` sh
Processing by Api::V1::HomeController#index as JSON

Filter chain halted as :authenticate rendered or redirected

Completed 401 Unauthorized in 1ms (Views: 0.2ms | ActiveRecord: 0.0ms | Allocations: 241)
```

Adesso proviamo seguente modo:
```sh
 curl -X GET "localhost:3000/api/v1/home/index"  -H "Authorization: Bearer mytoken"
```

Si avvia il `debugger`

Modifichiamo il nostro controller `app/controllers/api/v1/autehnticated_controller.rb`

```ruby
class Api::V1::AuthenticatedController < ActionController::Base
    before_action :authenticate

    def authenticate
        authenticate_user_with_token || handle_bad_authentication
    end

    private

    def authenticate_user_with_token
        #authenticate_with_http_token
        #Authenticate using an HTTP Bearer token. Returns true if authentication is successful, false otherwise.

        #Autenticarsi utilizzando un token di connessione HTTP. Restituisce vero se l'autenticazione ha esito positivo, falso altrimenti.
        authenticate_with_http_token do |token, options|
            @current_api_token = ApiToken.where(active: true).find_by(token: token)
            debugger
        end 
    end

    #...
    #...
end 
```

Lanciamo nuovamente la nostra richiesta api:
```sh
 curl -X GET "localhost:3000/api/v1/home/index"  -H "Authorization: Bearer mytoken"
```

Passiamo al debugger:
``` sh
  @current_api_token = ApiToken.where(active: true).find_by(token: token)
```
Possiamo vedere che il token è nil perche non è un token valido:

``` ruby
(ruby) @current_api_token = ApiToken.where(active: true).find_by(token: token)

  CACHE ApiToken Load (0.0ms)  SELECT "api_tokens".* FROM "api_tokens" WHERE "api_tokens"."active" = $1 AND "api_tokens"."token" = $2 LIMIT $3  [["active", true], ["token", "[FILTERED]"], ["LIMIT", 1]]

  ↳ (rdbg)//Users/antoninoscaffidi/development/AMVIdealab/ruby-3-2-2/demo-ecommerce/app/controllers/api/v1/authenticated_controller.rb:1:in `block in authenticate_user_with_token'

nil 
```

Adesso commentiamo il debugger.


Adesso, passiamo un token valido alla nostra richiesta:

``` ruby
user = User.first

  User Load (0.6ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT $1  [["LIMIT", 1]]

=>
#<User:0x00000001121e5290
 id: 3,
 name: "Antonino",
 email: "antoninoscaffidi@gmail.com",
 password_digest: "[FILTERED]",
 created_at: Wed, 04 Oct 2023 02:04:00.398186000 UTC +00:00,
 updated_at: Wed, 04 Oct 2023 02:04:00.398186000 UTC +00:00>


user.api_tokens.first.token

  ApiToken Load (0.8ms)  SELECT "api_tokens".* FROM "api_tokens" WHERE "api_tokens"."user_id" = $1 ORDER BY "api_tokens"."id" ASC LIMIT $2  [["user_id", 3], ["LIMIT", 1]]

=> "ae7f32f8316e8cda1c44a98d233cdfc7"
```

Ok, abilitiamo il debugger nel nostro controller ` app/controllers/api/v1/authenticated_controller.rb` e lanciamo:

```sh 
curl -X GET "localhost:3000/api/v1/home/index"  -H "Authorization: Bearer ae7f32f8316e8cda1c44a98d233cdfc7"
```

Adesso come possiamo vedere nel debugger , `@curren_api_token` ritorna un API token corretto. 

Modifichiamo il nostro controller `app/controllers/api/v1/authenticated_controller.rb`

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
    before_action :authenticate
    #...
    #...
    private

    def authenticate_user_with_token
        authenticate_with_http_token do |token, options|
           #...
            @current_user = @current_api_token&.user
           #...
        end 
    end

    #....
end 
```
#safe navigation operator (&.): tells Ruby to only call the next method if the receiver isn’t nil. Otherwise, the expression returns nil.


Adesso definiamo due attributi attr_reader in `app/controllers/api/v1/authenticated_controller.rb ` , in modo da poterli urilizzare facilemnte negli altri controller:

``` ruby
class Api::V1::AuthenticatedController < ActionController::Base
    before_action :authenticate

    attr_reader :current_api_token, :current_user
    #...
    #...

end  
```
Adesso possiamo anche commentare il ` debugger`

``` ruby

class Api::V1::AuthenticatedController < ActionController::Base
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
        render json: {message: "Bad credentials!"}, status: :unauthorized
    end
end 
```

Ok, adesso possiamo utilizzare, grazie ad `attr_reader`, le variabile `current_api_token` e `current_user` anche negli altri controller. Modifichiamo il nostro controller `app/controllers/api/v1/home_controller.rb`

``` ruby
class Api::V1::HomeController < Api::V1::AuthenticatedController
    def index
        #render json: {message: "Hello API world!"}
        render json: {current_api_token: current_api_token.id, current_user: current_user.email}
    end
end

```

Lanciamo da terminale:
``` sh
curl -X GET "localhost:3000/api/v1/home/index"  -H "Authorization: Bearer ae7f32f8316e8cda1c44a98d233cdfc7"
```

ed otteniamo:

```sh
{"current_api_token":1,"current_user":"antoninoscaffidi@gmail.com"}% 
```

Adesso creaimo il nostro primo test:

Creiamo una cartella api sotto `test/integration/api` e al suo interno defiamo un file `home_controlle_test.rb` 

``` ruby
require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
    test 'When aurh token is valid ' do 
        get api_v1_home_index_path
        assert_response :success
    end
end 
```

Lanciamo il comando:
```sh
rails test 
```

```sh
Failure:
HomeControllerTest#test_When_aurh_token_is_not_valid_ [/Users/antoninoscaffidi/development/AMVIdealab/ruby-3-2-2/demo-ecommerce/test/integration/api/home_controller_test.rb:6]:
Expected response to be a <2XX: success>, but was a <401: Unauthorized>
Response body: {"message":"Bad credentials!"} 
```

Adesso modifichimao il nostro file di test: `test/integration/api/home_controller_test.rb`

``` ruby
require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
    test 'When aurh token is valid ' do 
        user = users(:one)
        api_token = user.api_tokens.create!
        get api_v1_home_index_path, headers: {HTTP_AUTHORIZATION: "Token token=#{api_token.token}"}
        assert_response :success
    end
end
```

Ok, il test è andato a buon fine:

Gestiamo il caso in cui, un utente non è autorizzato:

``` ruby

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
    test 'When aurh token is valid ' do 
        user = users(:one)
        api_token = user.api_tokens.create!
        get api_v1_home_index_path, headers: {HTTP_AUTHORIZATION: "Token token=#{api_token.token}"}
        assert_response :success
        assert_includes response.body, user.email
    end

    test 'When aurh token is inactive ' do 
        user = users(:one)
        api_token = user.api_tokens.create!
        api_token.update!(active: false)
        get api_v1_home_index_path, headers: {HTTP_AUTHORIZATION: "Token token=#{api_token.token}"}
        assert_response :unauthorized
        assert_includes response.body, 'Bad credentials' 
    end
end

```
