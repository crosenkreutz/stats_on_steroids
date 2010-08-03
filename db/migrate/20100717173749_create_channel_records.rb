class CreateChannelRecords < ActiveRecord::Migration
  def self.up
    create_table :channel_records do |t|
      t.datetime :date
      t.integer :signups
      t.integer :activations
      t.integer :firstcalls
      t.integer :brand_id
      t.integer :channel_id
      t.integer :processed_file_id
      t.datetime :file_date

      t.timestamps
    end
  end

  def self.down
    drop_table :channel_records
  end
end
