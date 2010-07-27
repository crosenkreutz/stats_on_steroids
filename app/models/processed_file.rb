class ProcessedFile < ActiveRecord::Base

  belongs_to :brand
  has_many :channel_records

end
