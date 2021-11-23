require_relative 'lib'
out = Input.new.curl
PrintTable.table(out, "WGET")
#SaveBar.new(out, "test.png", json: true, show_labels: true).create_bar