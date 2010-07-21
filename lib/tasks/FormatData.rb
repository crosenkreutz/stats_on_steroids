require 'rubygems'
require 'nokogiri'
require 'time'
require 'parsedate'

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

  (0..tables.count-1).each do |i|

    table = tables[i]
    heading = headings[i].content.slice(/(^.+) Summary/,1)
    heading = "Shop" unless heading
		      
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

	puts "#{heading}, #{date_string}: #{signups}, #{activations}, #{firstcalls}"	

      end

    end

  end

  totals = report.xpath('//b[contains(text(),"14 Days")][1]/preceding-sibling::table[1]/tr/td')

  active = nil
  signups = totals.children[0].text.to_i
  activations = totals.children[1].text.to_i
  firstcalls = totals.children[2].text.to_i
  active = totals.children[3].text.to_i unless totals.children[3].nil?

  brand_id = Brand.find_by_name("Fonic").id

  existing_total_record = TotalRecord.find_by_date(latest_date_string)

  if existing_total_record.nil? then

    TotalRecord.create(:date => latest_date_string, :signups => signups, :activations => activations, :firstcalls => firstcalls, :active => active, :brand_id => brand_id)

  else

    puts "Total record for #{latest_date_string} exists already!"

  end

end
