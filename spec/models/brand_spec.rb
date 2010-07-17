require 'spec_helper'

describe Brand do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :brand_type => "value for brand_type"
    }
  end

  it "should create a new instance given valid attributes" do
    Brand.create!(@valid_attributes)
  end
end
