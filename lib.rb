require 'json'
require 'gruff'
require 'net/ssh'
require 'net/scp'
require 'date'


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
    def initialize(file_name="/home/cowrie/cowrie/var/log/cowrie/cowrie.json", out = Date.today.to_s + "-cowrie.json")
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
    def get_logs
        # Get all the cowrie.json logs & save the file names
        # into an array.
        filenames = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                filenames << file_name
            end
        end
    return filenames
    end
    def clean_data(array)
        h = {}
        # 0 = login
        # 1 = ip
        array.each do |ii|
            if h.has_key?(ii)
                h[ii] +=  1
            else 
                h[ii] = 1
            end       
        end
        return h.sort_by{|k,v| -v}
    end
end
class Login < Main
    def initialize(type: "success")
        @logs    = get_logs
        @type    = type
        @session = session
    end
    def switch
        if @type.to_s == "failed"
            return EventId.login_failed.to_s
        elsif @type.to_s == "success"
            return EventId.login_success.to_s
        end
    end
    def run
        ips = []
        @logs.each do |fn|
            File.readlines(fn).each do |l|
                begin
                    j = JSON.parse(l)
                    if j["eventid"].to_s == switch.to_s
                         ips << [ j["message"].split("[")[1].split("]")[0], j["src_ip"] ]
                    end
                rescue => e
                end
            end
        end
    return clean_data(ips, 0, state=false)
    end
    def session
        sess = []
        logs = @logs
        logs.each do |fn|
            p fn
            File.readlines(fn).each do |l|
                begin
                    j = JSON.parse(l)
                    if j["eventid"].to_s == switch.to_s
                        sess << j["session"]
                    end
                rescue => e
                end
            end
        end
    return clean_data(sess)
    end
end
class Input < Main
    def initialize(session: nil)
        @logs  = get_logs
        @session = session
    end
    def input
        cmd = []
        @logs.each do |fn|
            File.readlines(fn).each do |json|
                begin
                    j = JSON.parse(json)
                    if j["eventid"].to_s == EventId.cmd_input.to_s
                         cmd << [ j["input"], j["src_ip"]]
                    end
                rescue
                end
            end
        end
    return clean_data(cmd, 0, state=true)
    end
    def wget
        wget = []
        @logs.each do |fn|
            File.readlines(fn).each do |json|
                begin
                    j = JSON.parse(json)
                    if j["eventid"].to_s == EventId.cmd_input.to_s
                        if j["input"].include?("wget")
                            cmd << [ j["input"], j["src_ip"]]
                        end
                    end
                rescue
                end
            end
        end
    return clean_data(cmd.uniq, 0, state=true)
    end
    def curl
        curl = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == EventId.cmd_input.to_s
                            if j["input"].include?("curl")
                                wget << [ j["input"], j["src_ip"] ]
                            end
                        end
                    rescue
                    end
                end
            end
        end
        return clean_data(curl, 0, state=true)
    end
    def search_session
        if !@session.nil?
            sess = []
            @logs.each do |fn|
                File.readlines(fn).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == EventId.cmd_input.to_s
                            if j["session"].to_s == @session
                                sess << [ j["input"], j["src_ip"]]
                            end
                        end
                    rescue
                    end
                end
            end
        end
    return clean_data(sess, 0, state=true)
    end
end
class Downloads < Main
    def initialize
        @logs  = get_logs
    end
    def dl_file(raw: false)
        dl = []
        Dir['*'].each do |file_name|
            if file_name.include?("cowrie")
                File.readlines(file_name).each do |json|
                    begin
                        j = JSON.parse(json)
                        if j["eventid"].to_s == EventId.dl_file.to_s
                            if !j["destfile"].nil?
                                dl << [ j["destfile"], j["src_ip"] ]
                            end
                        end
                    rescue
                    end
                end
            end
        end
        if !raw
            return clean_data(dl, 0, state=true)
        else
            return dl
        end
    end

end
class EventId
    def initialize(id = 0)
        @id = id
    end
    def json
        {"login_failed":  "cowrie.login.failed",
         "login_success": "cowrie.login.success",
         "cmd_input":     "cowrie.command.input",
         "dl_file":       "cowrie.session.file_download",
         "tcpip":         "cowrie.direct-tcpip.request",
         "closed":        "cowrie.session.closed"}
    end
    def self.dl_file
        return "cowrie.session.file_download"
    end
    def self.login_failed
        return "cowrie.login.failed"
    end
    def self.login_success
        "cowrie.login.success"
    end
    def self.cmd_input
        "cowrie.command.input"
    end
    def self.tcpip
        "cowrie.direct-tcpip.request"
    end
    def self.closed
        "cowrie.session.closed"
    end
    def type
        if @id.to_i == 1
            return "cowrie.login.failed"
        elsif @id.to_i == 2
            return "cowrie.login.success"
        elsif @id.to_i == 3
            return "cowrie.command.input"
        elsif @id.to_i == 4
            return "cowrie.session.file_download"
        elsif @id.to_i == 5
            return "cowrie.direct-tcpip.request"
        elsif @id.to_i == 6
            return "cowrie.session.closed"
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
    @g.write(@out)
  end
end

class PrintTable
    def table(k, h1, h2: "Count")
        table = Terminal::Table.new
        table.headings = [h1, h2]
        table.rows     = k
        table.style    = {:width => @width, :border => :unicode_round, :alignment => :center }
        puts table
    end
end
#p Downloads.new.dl_file(raw: true)
p Login.new(type: "success").session
#p Input.new(session: "77a53223db2b").search_session
