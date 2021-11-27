# Cowrie-Log-ToolKit

# config.json
```json
{
    "ip": "",
    "uname": "root",
    "pass": "",
    "port": 67
}
```

The file, config.json needs to be in the same directory for SSH or SCP to work. 

Example of this can be seen in ssh.rb

# wget.rb
```ruby
require_relative 'lib'
out = Input.new.wget
SaveBar.new(out, "test.png", json: true, show_labels: true).create_bar
```

# input
```ruby
require_relative 'lib'
inputs  = Input.new
inputs.input.each do |i, ii|
    puts "#{ii}] " + i
end

p inputs.wget
```

# Get Login Data
```ruby
require_relative 'lib'
require 'date'
log = Login.new
s   = log.run
SaveBar.new(s, Date.today.to_s + "-LOGIN-success.png", json: true, show_labels: true, title: "Successful Logins").create_bar


log.type = "failed"
f        = log.run
SaveBar.new(f, Date.today.to_s + "-LOGIN-failed.png", json: true, show_labels: true, title: "Failed Logins").create_bar
```