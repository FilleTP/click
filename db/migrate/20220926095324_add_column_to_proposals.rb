class AddColumnToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :holded_id, :string
  end
end
