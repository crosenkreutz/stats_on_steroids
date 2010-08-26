class BrandsController < ApplicationController
  def index
    @brands = Brand.all
  end
  
  def show
    @brand = Brand.find(params[:id])
    @channels = @brand.channels
    @total_records = @brand.total_records.sort_by(&:file_date)
    @channel_records = @brand.channel_records
  end
  
  def simple_stat
    @brand = Brand.find(params[:id])
  end
  
end
