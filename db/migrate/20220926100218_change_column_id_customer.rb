class ChangeColumnIdCustomer < ActiveRecord::Migration[6.1]
  def change
    rename_column :customers, :customer_id, :holded_id
  end
end
