class TotalRecord < ActiveRecord::Base

  belongs_to :brand
  belongs_to :processed_file

end
