class ChannelRecord < ActiveRecord::Base

  belongs_to :brand
  belongs_to :channel
  belongs_to :processed_file

end
