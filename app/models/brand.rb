class Brand < ActiveRecord::Base

  has_many :channel_records
  has_many :channels, :through => :channel_records

end
