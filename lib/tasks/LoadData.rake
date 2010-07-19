require './lib/tasks/FormatData'

task :AutomaticDownload => :environment do
  FormatAndStore()
end
