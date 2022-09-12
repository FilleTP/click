class CreatePvgisdata < ActiveRecord::Migration[6.1]
  def change
    create_table :pvgisdata do |t|
      t.float :lat
      t.float :lon
      t.float :peakpower
      t.float :angle
      t.float :loss
      t.float :slope
      t.string :azimuth
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
