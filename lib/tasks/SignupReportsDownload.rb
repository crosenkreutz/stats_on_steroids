require 'open-uri'
require 'rubygems'
require 'mechanize-ntlm'
require 'highline/import'

def encoding_convert(s)

  link = s.slice(/"(\S*)"/, 1)

  link.gsub!(/\\u002f/, '/')
  link.gsub!(/\\u0026/, '&')
  link.gsub!(/\\u002520/, ' ')
  link.gsub!(/\\u00252e/, '.')
  link.gsub!(/\\u00257b/, '{')
  link.gsub!(/\\u00252d/, '-')
  link.gsub!(/\\u00257d/, '}')

  return link

end

def get_email_links(agent, folder_brand_name = nil)
  
  links = agent.page.links
  email_links = links.find_all { |link| link.text =~ /.eml/ }

  email_links.each do |email_link|

    brand_name = nil

    if !folder_brand_name
      
      brand_name = email_link.text.slice(/(.+) Signup/,1)

    else

      brand_name = folder_brand_name

    end

    get_email(email_link, brand_name)

  end

end

def get_email(email_link, brand_name)

  if !File.exist? "#{$path}#{brand_name}/#{email_link.text}"

    if !File.exist? "#{$path}#{brand_name}"

      puts "Creating directory #{brand_name}"
      FileUtils.mkdir_p "#{$path}#{brand_name}"
      
    end

    puts "Downloading #{brand_name}/#{email_link.text}"
    email_link.click.save("#{$path}#{brand_name}/#{email_link.text}")

  end
  
end

config_file = File.open("config", "r")

config_file.each_line do |line|

  key, value = line.split(':')
  value.strip!

  $path = value if key == 'Path'

end

user_name = ask("Input User Name: ")
user_name = user_name.chomp
password = ask("Input Password: ") {|q| q.echo = false}
password = password.chomp

agent = WWW::Mechanize.new
agent.basic_auth("#{user_name}", "#{password}")

agent.get("https://sps.o2service.de/OPERATIONS/Pages/default.aspx")

links = agent.page.links
signup_links = links.find_all { |link| link.text =~ /^Signup\.*/ }

signup_links.each do |signup_link|

  signup_link.click

  next_link_js = agent.page.link_with(:text => 'Next')
  get_email_links(agent)

  while next_link_js

    next_link = encoding_convert(next_link_js.attributes["onclick"])
    agent.get(next_link)
    next_link_js = agent.page.link_with(:text => 'Next')
    get_email_links(agent)

  end

  signup_link.click

  links = agent.page.links
  brand_links = links.find_all { |link| link.text =~ /Folder/ }

  brand_links.each do |brand_link|

    brand_name = brand_link.text.slice(/Folder: (.+) Signup/,1)
    brand_name.sub!(/VZ Mobil\z/,"VZ Mobile")

    brand_link.click

    get_email_links(agent, brand_name)

  end

end
