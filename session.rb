require_relative 'lib'

args = ARGV
s    = Session.new
session = s.input
#.first(10)
s.raw = true
l = []

session.each do |i|
    if i[1].include?("2sh")
        l << i[0]
    end
end
p l
inputs  = Input.new
l.each do |ss|
    inputs.session = ss.to_s
    inputs.search_session.each do |i|
        puts i.shift
        #puts i[0].to_s + " " + i[1].to_s.red
    end
end