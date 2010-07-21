class DropBrandTypeFromBrand < ActiveRecord::Migration
  def self.up
    remove_column :brands, :brand_type
  end

  def self.down
  end
end
