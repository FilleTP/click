class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :code
      t.string :email
      t.string :mobile
      t.string :phone
      t.string :customer_id
      t.string :type
      t.boolean :is_person
      t.string :iban
      t.string :swift
      t.string :sepa_ref
      t.integer :group_id
      t.string :tax_operation
      t.string :client_record
      t.string :supplier_record
      t.string :bill_address
      t.string :shipping_addresses
      t.string :website
      t.text :note
      t.string :contact_persons

      t.timestamps
    end
  end
end
