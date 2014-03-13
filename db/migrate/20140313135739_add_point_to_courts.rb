class AddPointToCourts < ActiveRecord::Migration
  def change
    add_column :courts, :point, :geometry
  end
end
