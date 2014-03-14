class AddPointToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :point, :geometry
    add_index :courts, :point, spatial: true
  end
end
