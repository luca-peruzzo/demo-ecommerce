## Gestione dell'azienda

In questa sezione viene spiegata come è stato modellata la base della nostra applicazione web.

Iniziamo con la crezione del modello `Company`. Eseguiamo il seguente commando nel terminale:

```ruby
bin/rails generate model Company name:string description:text tag_title:string meta_description:text web_site:string
```

Questo comando creerà il modello `app/models/company.rb`

``` ruby
class Company < ApplicationRecord
   
end
```

Inoltre verrà creato  anche un file di migrazione [timestamp]_create_companies.rb

``` ruby
class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.string :tag_title
      t.text :meta_description

      t.timestamps
    end
  end
end 
```

Per redere effettive le modifiche sul database e quindi creare la tabella ` companies`, bisogna eseguire il comando:

```ruby
bin/rails db:migrate
```

Adesso sul nostro database ci sarà una tabella `companies`

```psql
  Column      |              Type              | Collation | Nullable |                Default
------------------+--------------------------------+-----------+----------+---------------------------------------
 id               | bigint                         |           | not null | nextval('companies_id_seq'::regclass)
 name             | character varying              |           |          |
 description      | text                           |           |          |
 tag_title        | character varying              |           |          |
 meta_description | text                           |           |          |
 created_at       | timestamp(6) without time zone |           | not null |
 updated_at       | timestamp(6) without time zone |           | not null |
 web_site         | character varying              |           |          |
Indexes:
    "companies_pkey" PRIMARY KEY, btree (id)
```

