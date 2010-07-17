require 'spec_helper'

describe TotalRecord do
  before(:each) do
    @valid_attributes = {
      :date => Date.today,
      :signups => 1,
      :activations => 1,
      :firstcalls => 1,
      :active => 1,
      :brand_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    TotalRecord.create!(@valid_attributes)
  end
end
