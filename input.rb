require_relative 'lib'
require "colorize"
# gem install colorize
args = ARGV


inputs  = Input.new
if ARGV[0] == "-input"
    inputs.input.each do |i, ii|
        puts "#{ii}] " + i
    end
elsif  ARGV[0] == "-wget"
    inputs.wget.each do |wget|
        puts wget
    end
elsif ARGV[0] == "-session"
    inputs.session = "338ecdfe0b71"
    inputs.search_session.each do |i|
        puts i[0].to_s + " " + i[1].to_s.red
    end


end
