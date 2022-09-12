class CreatePvgis < ActiveRecord::Migration[6.1]
  def change
    create_table :pvgis do |t|
      t.string :name
      t.text :month1
      t.text :month2
      t.text :month3
      t.text :month4
      t.text :month5
      t.text :month6
      t.text :month7
      t.text :month8
      t.text :month9
      t.text :month10
      t.text :month11
      t.text :month12
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
