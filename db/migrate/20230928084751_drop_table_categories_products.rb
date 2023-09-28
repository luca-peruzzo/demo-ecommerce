class DropTableCategoriesProducts < ActiveRecord::Migration[7.0]
  def change
    drop_table :categories_products, if_exists: true
  end
end
