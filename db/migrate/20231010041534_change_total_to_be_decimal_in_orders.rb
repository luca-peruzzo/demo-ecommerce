class ChangeTotalToBeDecimalInOrders < ActiveRecord::Migration[7.0]
  def change
    change_column :orders, :total, :decimal
  end
end
