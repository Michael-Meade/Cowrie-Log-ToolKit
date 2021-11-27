require_relative 'lib'
require 'date'
arg = ARGV 
log = Login.new
if arg[0] == "-success"
    s   = log.run
    SaveBar.new(s, Date.today.to_s + "-LOGIN-success.png", json: true, show_labels: true, title: "Successful Logins").create_bar
elsif arg[0] == "-failed"
    log.type = "failed"
    f        = log.run
    SaveBar.new(f, Date.today.to_s + "-LOGIN-failed.png", json: true, show_labels: true, title: "Failed Logins").create_bar
elsif arg[0] == "-session"
    sessions = log.session
    p sessions
end