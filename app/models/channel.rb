class Channel < ActiveRecord::Base

  has_many :channel_records
  has_many :brands, :through => :channel_records

end
