require 'rubygems'
require 'nokogiri'
require 'time'
require 'parsedate'

def UpdateRecord(db_record, new_record, kind)

  db_sum = db_record.signups + db_record.activations + db_record.firstcalls
  new_sum = new_record.signups + new_record.activations + new_record.firstcalls

  if (kind == "total") && new_record.active then

    db_sum += db_record.active
    new_sum += new_record.active

  end

  if new_sum > db_sum then

    db_record.signups = new_record.signups
    db_record.activations = new_record.activations
    db_record.firstcalls = new_record.firstcalls
    db_record.active = new_record.active if (kind == "total") && new_record.active
    db_record.save

  end 

end

def FormatAndStore()

  config_file = File.open("./lib/tasks/config", "r")
  path = ''

  config_file.each_line do |line|

    key, value = line.split(':')
    value.strip!

    path = value if key == 'Path'

  end

  latest_date = 0
  latest_date_string = ""
  report = Nokogiri::HTML(open("#{path}Fonic/Original Message 5163.eml"))

  headings = report.xpath('//b[contains(text(),"14 Days")]')
  tables = report.xpath('//b[contains(text(),"14 Days")][1]/following::table')

  brand_id = Brand.find_by_name("Fonic").id

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

      date_string = table_tds[0].content
      if date_string =~ /\d{4}-\d{2}-\d{2}/ then

        date_array = ParseDate::parsedate(date_string)
        date = Time.local(*date_array).to_i
	if date > latest_date then
          latest_date = date
	  latest_date_string = date_string
	end

	signups = table_tds[1].text.to_i
	activations = table_tds[2].text.to_i
	firstcalls = table_tds[3].text.to_i

        new_channel_record = ChannelRecord.new(:date => date_string, :signups => signups, :activations => activations, :firstcalls => firstcalls, :brand_id => brand_id, :channel_id => channel_id)

        existing_channel_record_list = ChannelRecord.find(:all, :conditions => {:date => date_string, :brand_id => brand_id, :channel_id => channel_id})

        if existing_channel_record_list.empty? then

          new_channel_record.save

        else

          UpdateRecord(existing_channel_record_list[0], new_channel_record, "channel")

        end

      end

    end

  end

  totals = report.xpath('//b[contains(text(),"14 Days")][1]/preceding-sibling::table[1]/tr/td')

  active = nil
  signups = totals.children[0].text.to_i
  activations = totals.children[1].text.to_i
  firstcalls = totals.children[2].text.to_i
  active = totals.children[3].text.to_i unless totals.children[3].nil?

  new_total_record = TotalRecord.new(:date => latest_date_string, :signups => signups, :activations => activations, :firstcalls => firstcalls, :active => active, :brand_id => brand_id)

  existing_total_record = TotalRecord.find_by_date(latest_date_string)

  if existing_total_record.nil? then

    new_total_record.save

  else

    UpdateRecord(existing_total_record, new_total_record, "total")

  end

end
