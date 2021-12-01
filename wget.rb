require_relative 'lib'
out = Input.new.wget
p out
SaveBar.new(out, "test.png", json: true, show_labels: true).create_bar