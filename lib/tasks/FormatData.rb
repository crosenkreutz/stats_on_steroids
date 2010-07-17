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
  report = Nokogiri::HTML(open("#{path}Fonic/Original Message 3951.eml"))

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
        latest_date = date if date > latest_date
        puts date

        table_tds[1..table_tds.length].each do |table_td|

          puts table_td.text
      
        end

      end

    end

  end

  puts latest_date

  report.xpath('//b[contains(text(),"14 Days")][1]/preceding-sibling::table[1]/tr/td').each { |child| puts child.text.to_i }

end
