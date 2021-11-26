require_relative 'lib'
inputs  = Input.new
inputs.input.each do |i, ii|
    puts "#{ii}] " + i
end

p inputs.wget