class Brand < ActiveRecord::Base

  has_many :channel_records
  has_many :total_records
  has_many :processed_files
  has_many :channels, :through => :channel_records, :uniq => true

end
