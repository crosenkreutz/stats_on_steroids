# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def date_number_array(records, prop)

    @arr = "["
    records.each {|record|
      if !record[prop].nil?
        date = record.file_date.to_i * 1000
        number = record[prop].to_f
      	@arr += "[#{date}, #{number}],"
      end
    }
    @arr +="]"
    return @arr

  end

  def date_ratio_array(records, numerator, denominator)

    @arr = "["
    records.each {|record|
      ratio = record.ratio(numerator, denominator)
      if ratio.finite? && ratio != 0.0
        date = record.file_date.to_i * 1000
	@arr += "[#{date}, #{ratio}],"
      end
    }
    @arr += "]"
    return @arr

  end

  def contributions(records, channels)

    @total = records.sum(:signups).to_f
    @arr = "["
    channels.each {|channel|
      records_in_channel = records.sum(:signups, :conditions => {:channel_id => channel.id})
      percentage = records_in_channel.to_f / @total * 100.0
      @arr += "['#{channel.name}', %.2f]," % percentage
    }
    @arr += "]"
    puts @arr
    return @arr

  end

end
