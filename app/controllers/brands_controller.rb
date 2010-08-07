class BrandsController < ApplicationController
  def index
    @brands = Brand.all
  end
  
  def show
    @brand = Brand.find(params[:id])
    @channels = @brand.channels
    @total_records = @brand.total_records.sort_by(&:file_date)
  end
  
  def simple_stat
    @brand = Brand.find(params[:id])
  end
  
end
