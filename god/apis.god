%w{beta sandbox production}.each do |tire|
  God.watch do |w|
    w.name = "#{tire}_grouper"
    w.group = "#{tire}"
    w.log = "/var/www/#{tire}.hoccer.com/v3/grouper/log/thin.log"

    thin_monitoring(w, {:service => "grouper", :tire => tire})

    # restart if service does not respond
    w.transition(:up, :restart) do |on|
      on.condition(:http_response_code) do |c|
        c.host = 'localhost'
        c.port = get_port "grouper", tire
        c.code_is_not = 200
        c.notify = @developer_alert
      end
    end unless tire == 'beta'
  end

  God.watch do |w|
    w.name = "#{tire}_linccer"
    w.group = "#{tire}"
    w.log = "/var/www/#{tire}.hoccer.com/v3/linker/log/thin.log"

    thin_monitoring(w, {:service => "linccer", :tire => tire})

    # restart if service does not respond
    w.transition(:up, :restart) do |on|
      on.condition(:http_response_code) do |c|
        c.host = 'localhost'
        c.port = get_port "linccer", tire
        c.path = '/clients/94dc1860-fa20-012d-7128-00163e001ab0/action/one-to-many'
        c.code_is_not = 204
        c.notify = @developer_warn
      end
    end unless tire == 'beta'

  end

  God.watch do |w|
    w.interval = 30.seconds
    w.start_grace = 20.seconds
    w.restart_grace = 20.seconds
    w.name = "#{tire}_filecache"
    w.group = "#{tire}"
    w.log = "/var/www/filecache.#{tire}.hoccer.com/log/node.log"
    w.env = { 'NODE_PATH' => "/home/xadmin/.node_libraries" }

    deamon = "/usr/local/bin/node"

    w.start = "/usr/local/bin/node /var/www/filecache.#{tire}.hoccer.com/filecache.js --port=#{get_port( 'filecache', tire)}"
    #w.stop = "mongo --eval 'db.shutdownServer();' admin"

    w.behavior(:clean_pid_file)

    apply_default_state_transitions(w, {:memory_max => 900.megabytes})

  end

end

God.watch do |w|
  w.interval = 30.seconds
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.name = "production_monitor"
  w.group = "production"
  w.log = "/var/www/monitor.hoccer.com/log/node.log"

  deamon = "/usr/local/bin/node"

  w.start = "node /var/www/monitor.hoccer.com/worldaction.js --port=8090"

  w.behavior(:clean_pid_file)

  apply_default_state_transitions(w, {:memory_above => 900.megabytes})

end
