require './lib/tasks/FormatData'
require './lib/tasks/DataExport'

task :AutomaticDownload => :environment do
  FormatAndStore()
end

task :DataDump => :environment do
  DataExport()
end