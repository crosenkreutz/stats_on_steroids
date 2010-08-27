require 'ftools'

def configuration

  config_file = File.open("./lib/tasks/config", "r")
  config_file.each_line do |line|

    key, value = line.split(':')
    value.strip!
    $data_path = value if key == 'DataPath'

  end
    
end

def DataExport

  configuration()
  Brand.all.each do |brand|
  FileUtils.mkdir_p "#{$data_path}#{brand.name}"
  
    totals_file = File.new("#{$data_path}#{brand.name}/#{brand.name}_totals.dat", "w")
    totals_records = brand.total_records.sort_by(&:file_date)
    puts "Writing to #{brand.name}/#{brand.name}_totals.dat"
    totals_records.each do |record|

      if record.active then
        totals_file.puts "#{record.file_date.to_i}\t#{record.signups}\t#{record.activations}\t#{record.firstcalls}\t#{record.active}"
      else
        totals_file.puts "#{record.file_date.to_i}\t#{record.signups}\t#{record.activations}\t#{record.firstcalls}\t-1"
      end

    end
    totals_file.close()

    brand.channels.each do |channel|

      channel_file = File.new("#{$data_path}#{brand.name}/#{brand.name}_#{channel.name}.dat", "w")

      channel_records = brand.channel_records.find(:all, :conditions => {:channel_id => channel.id}).sort_by(&:date)

      puts "Writing to #{brand.name}/#{brand.name}_#{channel.name}.dat"
      channel_records.each do |record|

        channel_file.puts "#{record.date.to_datetime.to_i}\t#{record.signups}\t#{record.activations}\t#{record.firstcalls}"

      end
      channel_file.close()   
    end  
  end
end