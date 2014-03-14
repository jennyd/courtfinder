class AddPointToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :geopoint, :point, geographic: true, srid: 4326
    add_index :courts, :geopoint, spatial: true
  end
end
