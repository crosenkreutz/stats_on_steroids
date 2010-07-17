class CreateTotalRecords < ActiveRecord::Migration
  def self.up
    create_table :total_records do |t|
      t.date :date
      t.integer :signups
      t.integer :activations
      t.integer :firstcalls
      t.integer :active
      t.integer :brand_id

      t.timestamps
    end
  end

  def self.down
    drop_table :total_records
  end
end
