require File.dirname(__FILE__) + '/../spec_helper'
 
describe ChannelRecordsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => ChannelRecord.first
    response.should render_template(:show)
  end
end
