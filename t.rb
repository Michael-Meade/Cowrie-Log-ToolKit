require 'json'
require 'terminal-table'

ips = []
Dir['*'].each do |file_name|
    if file_name.include?("cowrie")
        File.readlines(file_name).each do |json|
            begin
                j = JSON.parse(json)
                if j["eventid"].to_s == "cowrie.login.success"
                    ips << [ j["message"].split("[")[1].split("]")[0], j["src_ip"] ]
                end
            rescue
            end
        end
    end
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
def table(k, h1, h2: "Count")
    table = Terminal::Table.new
    table.headings = [h1, h2]
    table.rows     = k
    table.style    = {:width => @width, :border => :unicode_round, :alignment => :center }
    puts table
end

k = clean_data(ips, 0)
table(k, "Login")
k = clean_data(ips, 1)
table(k, "Login")