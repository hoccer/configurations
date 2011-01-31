pwd = File.dirname(__FILE__) 
$LOAD_PATH.unshift pwd + '/extensions' 
load "mongo_connections.rb" 

God.load "#{pwd}/contacts.god"
God.load "#{pwd}/common.god"

# watch linccer, grouper, filecache for all three tires (beta, sandbox, prod.)
God.load "#{pwd}/apis.god"

# watch mongo
God.load "#{pwd}/mongodbs.god"

God.watch do |w|
  
  w.interval = 30.seconds
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds

  w.name = "developer"
  w.group = "websites"
  w.log = "/var/www/developer.hoccer.com/developer/log/thin.log"

  w.start = "/usr/local/rvm/bin/developer_thin start -C /etc/thin/developer.yml"
  w.stop = "/usr/local/rvm/bin/developer_thin stop -C /etc/thin/developer.yml"
  
  w.pid_file = "/var/run/thin/developer.pid"
  w.behavior(:clean_pid_file)

  apply_default_state_transitions(w)

    # restart if page does not respond
    w.transition(:up, :restart) do |on|
      on.condition(:http_response_code) do |c|
        c.host = 'developer.hoccer.com'
        c.path = '/'
        c.code_is_not = 302 # should use 200, but https is not yet implemented in God
        c.notify = @developer_warn
      end
    end

end
