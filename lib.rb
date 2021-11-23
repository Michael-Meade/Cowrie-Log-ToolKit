require 'json'
require 'gruff'
require 'net/ssh'
require 'net/scp'
class SSH
    def initialize
        c      = Config.new
        @ssh   = Net::SSH.start(c.ip, c.uname, :password => c.pass, :port => c.port)
    end
    def login(cmd)
        return @ssh.exec!(cmd)
    end
end
class SCP
    def initialize(file_name="/home/cowrie/cowrie/var/log/cowrie/cowrie.json", out)
        @file_name = file_name
        @out       = out
    end
    def run
        c      = Config.new
        Net::SSH.start(c.ip, c.uname, :password => c.pass, :port => c.port) do |ssh|
            ssh.scp.download! "/home/cowrie/cowrie/var/log/cowrie/cowrie.json", @out
        end
    end
end
class DownloadFile < SSH
    def initialize(file_name, cmd = "cat /home/cowrie/cowrie/var/log/cowrie/cowrie.json")
        @file_name = file_name
        @cmd       = cmd
    end
    def dl_file
        txt   = SSH.new.login(@cmd)
        File.open(@file_name, 'w') { |f| f.write(txt) }
    end
end
class Config
    def initialize
        if File.exist?("config.json")
            @json = JSON.parse(File.read("config.json").to_s)
        end
    end
    def ip
        @json["ip"]
    end
    def uname
        @json["uname"]
    end
    def pass
        @json["pass"]
    end
    def port
        @json["port"]
    end
end
class Main
    def run
        ips = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == "cowrie.login.failed"
                            ips << [ j["message"].split("[")[1].split("]")[0], j["src_ip"] ]
                            #ips << [ j["message"].split("[")[1].split("]")[0], j["src_ip"] ]
                        end
                    rescue
                    end
                end
            end
        end
    return ips.uniq
    end
    def clean_data(array, o, state=true)
        h = {}
        # 0 = login
        # 1 = ip
        array.each do |ii|
            u = ii[o.to_i]
            if h.has_key?(u)
                h[u] +=  1
            else 
                h[u] = 1
            end       
        end
        if !state
            return h.sort_by{|k,v| -v}
        else 
            return h.sort_by{|k,v| -v}.first(10)

        end
    end
end

class SaveBar
  def initialize(file_name, out, title: nil, json: false, num: 10, show_labels: false, remove: false)
    @title       = title
    @out         = out
    @g           = Gruff::Bar.new(1000)
    @file_name   = file_name
    @json        = json
    @num         = num
    @show_labels = show_labels
    if !json
      @j         = JSON.parse(File.read(@file_name)).sort_by{|k,v| -v}.first(@num).to_h
    else 
        @j       = @file_name.sort_by{|k,v| -v}.first(@num)
    end
  end
  def color2
    ii = []
    t  = @num.times.map { "%06x" % (rand * 0xffffff) }.to_a
    t.each {|i| ii << "##{i}" }
    return ii
  end
  def create_bar
    @g.title  = @title
    @g.colors = color2
    @g.show_labels_for_bar_values = @show_labels
    #@g.group_spacing = 15
    @j.each do |data|
      @g.data(data[0], data[1])
    end
    p @out
    @g.write(@out)
  end
end
class Input < Main
    def input
        cmd = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == "cowrie.command.input"
                             cmd << [ j["input"], j["src_ip"]]
                        end
                    rescue
                    end
                end
            end
        end
    return clean_data(cmd.uniq, 0, state=true)
    end
    def wget
        wget = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == "cowrie.command.input"
                            if j["input"].include?("wget")
                                wget << [ j["input"], j["src_ip"] ]
                            end
                             #cmd << [ j["input"], j["src_ip"]]
                        end
                    rescue
                    end
                end
            end
        end
        return clean_data(wget.uniq, 0, state=true)
    end
    def curl
        curl = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == "cowrie.command.input"
                            if j["input"].include?("curl")
                                wget << [ j["input"], j["src_ip"] ]
                            end
                        end
                    rescue
                    end
                end
            end
        end
        return clean_data(curl.uniq, 0, state=true)
    end
end
=begin
out = Input.new.wget
p out


SaveBar.new(out, "test.png", json: true, show_labels: true).create_bar
=end