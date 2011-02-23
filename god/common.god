def apply_default_state_transitions(w, options = {})

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5
    end
    
    # check five times for this transition before a new 'start'
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.notify = @developer_alert
    end
  end

  # restart if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits)
  end 

  # restart if memory or cpu is too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 20
      options[:memory_max] |= 200.megabytes
      c.above = options[:memory_max]
      c.times = [3, 5]
      c.notify = @developer_info
    end
    
    on.condition(:cpu_usage) do |c|
      c.interval = 10
      c.above = 40.percent
      c.times = [3, 5]
      c.notify = @developer_info
    end
  end  

  w.lifecycle do |on|

    # if start or restart fails again and again...
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
      c.notify = @developer_alert
    end
  end
end

def thin_monitoring(w, options = {})
  w.interval = 30.seconds
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds

  thin = "/usr/local/rvm/bin/#{options[:service]}_#{options[:tire]}_thin"
  config = "/etc/thin/#{options[:service]}.#{options[:tire]}.yml"
  
  w.start = "#{thin} start -C #{config}"
  w.stop = "#{thin} stop -C #{config}"
  
  w.pid_file = "/var/run/thin/#{options[:service]}.#{options[:tire]}.pid"
  w.behavior(:clean_pid_file)  
  #File.chown(nil, 33, w.pid_file)
  #File.chmod(0664, w.pid_file)

  apply_default_state_transitions(w)
end

def get_port service, tire
  port = "9"

  port += "2" if tire == "beta"
  port += "3" if tire == "sandbox"
  port += "4" if tire == "production"

  port += "10" if service == "linccer"
  port += "11" if service == "grouper"
  port += "12" if service == "filecache"

  return port
end
