class CreateProcessedFiles < ActiveRecord::Migration
  def self.up
    create_table :processed_files do |t|
      t.string :name
      t.integer :brand_id

      t.timestamps
    end
  end

  def self.down
    drop_table :processed_files
  end
end
