require 'spec_helper'

describe ProcessedFile do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :brand_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    ProcessedFile.create!(@valid_attributes)
  end
end
