## DEMO ECOMMERCE - REST API

### CREAZIONE DEL NAMESPACE API::V1
Apriamo il file `config/routes.rb``

```ruby
    namespace :api, defaults: { format: :json } do
        namespace :v1 do
            get "home/index", to: "home#index"
            ...
            ...
            ...
        end
    end
```

