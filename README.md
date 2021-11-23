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