class ChannelRecordsController < ApplicationController
  def index
    @channel_records = ChannelRecord.all
  end
  
  def show
    @channel = Channel.find(params[:id])
    @brand = Brand.find(params[:brand_id])
    @channel_records = @channel.channel_records.find(:all, :conditions => {:brand_id => params[:brand_id]})
  end
end
