require 'rubygems'
require 'nokogiri'
require 'time'
require 'parsedate'
require 'ftools'

def Configuration()

  config_file = File.open("./lib/tasks/config", "r")
  path = ''

  config_file.each_line do |line|

    key, value = line.split(':')
    value.strip!

    path = value if key == 'Path'

  end

  return path

end

def UpdateRecord(db_record, new_record, kind)

  if new_record.file_date > db_record.file_date then

    db_record.signups = new_record.signups
    db_record.activations = new_record.activations
    db_record.firstcalls = new_record.firstcalls
    db_record.file_date = new_record.file_date
    db_record.active = new_record.active if (kind == "total") && new_record.active
    db_record.processed_file_id = new_record.processed_file_id
    db_record.save

  end 

end

def ProcessFile(file_name, brand_id, processed_file_id)

  report = Nokogiri::HTML(open(file_name))
  file_date_string = report.children[1].text.slice(/Date: [a-zA-Z]+, (.*) \+/,1)
  file_date = Time.local(*ParseDate.parsedate(file_date_string))

  headings = report.xpath('//b[contains(text(),"14")]')
  tables = report.xpath('//b[contains(text(),"14")][1]/following::table')

  (0..tables.count-1).each do |i|

    table = tables[i]
    heading = headings[i].content.slice(/(^.+) Summary/,1)
    heading = "Shop" unless heading

    if Channel.find_by_name(heading) then

      channel_id = Channel.find_by_name(heading).id

    else

      new_channel = Channel.create(:name => heading)
      channel_id = new_channel.id

    end
		      
    table_trs = table.css('tr')
    table_trs.each do |table_tr|

      table_tds = table_tr.css('td')
      
      if table_tds.count > 0 then

        date_string = table_tds[0].content
        if date_string =~ /\d{4}-\d{2}-\d{2}/ then

          date_array = ParseDate::parsedate(date_string)
          date = Time.local(*date_array)

  	  signups = table_tds[1].text.to_i
	  activations = table_tds[2].text.to_i
	  firstcalls = table_tds[3].text.to_i

          new_channel_record = ChannelRecord.new(:date => date, :signups => signups, :activations => activations, :firstcalls => firstcalls, :brand_id => brand_id, :channel_id => channel_id, :processed_file_id => processed_file_id, :file_date => file_date)

          existing_channel_record_list = ChannelRecord.find(:all, :conditions => {:date => date, :brand_id => brand_id, :channel_id => channel_id})

          if existing_channel_record_list.empty? then

            new_channel_record.save

          else

            UpdateRecord(existing_channel_record_list[0], new_channel_record, "channel")

	  end        

	end

      end

    end

  end

  totals = report.xpath('//b[contains(text(),"14")][1]/preceding-sibling::table[1]')
  totals_trs = totals.css('tr')
  totals_trs.each do |total_tr|

    totals_tds = total_tr.css('td')
    if totals_tds.count > 0 then
    
      active = nil
      signups = totals_tds[0].text.to_i
      activations = totals_tds[1].text.to_i
      firstcalls = totals_tds[2].text.to_i
      active = totals_tds[3].text.to_i unless totals_tds[3].nil?

      new_total_record = TotalRecord.new(:file_date => file_date, :signups => signups, :activations => activations, :firstcalls => firstcalls, :active => active, :brand_id => brand_id, :processed_file_id => processed_file_id)

      existing_total_record = TotalRecord.find(:all, :conditions => {:file_date => file_date, :brand_id => brand_id})

      if existing_total_record.empty? then

        new_total_record.save

      else

        UpdateRecord(existing_total_record[0], new_total_record, "total")

      end

    end

  end

end

def FormatAndStore()

  path = Configuration()
  Dir.chdir(path)
  brand_directories = Dir["*"]

  brand_directories.each do |brand_directory|

    if brand_directory != "Tchibo" then

      if Brand.find_by_name(brand_directory) then
    
        brand_id = Brand.find_by_name(brand_directory).id

      else

        new_brand = Brand.create(:name => brand_directory)
        brand_id = new_brand.id

      end

      Dir.chdir("#{path}#{brand_directory}")
      report_files = Dir["*"]

      report_files.each do |report_file|

        existing_file = ProcessedFile.find(:all, :conditions => {:brand_id => brand_id, :name => report_file})
      
        if existing_file.empty? then

          new_file = ProcessedFile.create(:brand_id => brand_id, :name => report_file)
          processed_file_id = new_file.id
          file_name = "#{path}#{brand_directory}/"+new_file.name
          puts "#{brand_directory}/"+new_file.name
          ProcessFile(file_name, brand_id, processed_file_id)

        end

      end

    end

  end

end
