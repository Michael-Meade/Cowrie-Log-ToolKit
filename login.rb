require_relative 'lib'
require 'date'
log = Login.new
s   = log.run
SaveBar.new(s, Date.today.to_s + "-LOGIN-success.png", json: true, show_labels: true, title: "Successful Logins").create_bar


log.type = "failed"
f        = log.run
SaveBar.new(f, Date.today.to_s + "-LOGIN-failed.png", json: true, show_labels: true, title: "Failed Logins").create_bar