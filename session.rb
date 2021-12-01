require_relative 'lib'
require 'naive_bayes'


args    = ARGV
s       = Session.new
session = s.input

s.raw   = true
l       = []
session.each do |i|
    if i[1].match("mdrfckr")
        l << i[0]
    end
end
p l
SaveData.new(name: "mdrfckr", data: l).save_json
=begin
def count(array)
    h = {}
    array.each do |ii|
        if !h.has_key?(ii)
            h[ii] = 1
        else 
            h[ii] += 1
        end
    end       
return h.sort_by{|k,v| -v}
end
ips     = []
inputs  = Input.new
l.each do |ss|
    inputs.session = ss.to_s
    inputs.search_session.each do |i|
        ips << i[1]
    end
end
out = count(ips)
p out
=end