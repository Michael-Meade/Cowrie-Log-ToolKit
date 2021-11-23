require_relative 'lib'
require 'date'
# get the apache2 logs on a remote server
#date = Date.today.to_s + "cowrie.json"
#d    = DownloadFile.new(date)
#d.dl_file
date = Date.today.to_s + "-cowrie.json"
SCP.new(date).run