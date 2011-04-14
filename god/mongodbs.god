God.watch do |w|

  w.interval = 30.seconds
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds

  w.name = "mongodb"
  w.group = "databases"

  logdir = "/var/log/mongodb"
  w.log = "#{logdir}/god-watch.log"
  w.pid_file = "/var/run/MongoDB.pid"

  deamon = "/usr/local/bin/mongod"
  database = "/var/lib/mongodb"

  w.start = "#{deamon} --fork --master --logpath #{logdir}/MongoDB.log --logappend --dbpath #{database} --bind_ip 127.0.0.1 --pidfilepath #{w.pid_file}"
  w.stop = "/usr/local/bin/mongo --eval 'db.shutdownServer();' admin"

  w.behavior(:clean_pid_file)

  apply_default_state_transitions(w)

  w.transition(:up, nil) do |on|

    on.condition(:mongo_connections) do |c|
      c.above = 400
      c.interval = 5.minutes
      c.notify = @developer_warn
    end

    on.condition(:disk_usage) do |c|
      c.interval = 1.hour
      c.above = 70.percent
      c.mount_point = "/"
      c.notify = @developer_warn
    end
  end

  w.transition(:up, :start) do |on|

    on.condition(:mongo_connections) do |c|
      c.above = 700
      c.interval = 2.minutes
      c.notify = @developer_alert
    end
  end

end
