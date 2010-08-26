class TotalRecord < ActiveRecord::Base

  belongs_to :brand
  belongs_to :processed_file

  def ratio(attr1, attr2)
    a = self[attr1].to_f
    a = 0.0 if a.nil? 
    b = self[attr2].to_f
    b = 0.0 if b.nil?
    a / b
  end

end
