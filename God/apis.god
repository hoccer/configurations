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
    w.name = "#{tire}_filecache"
    w.group = "#{tire}"
    w.log = "/var/www/filecache.#{tire}.hoccer.com/log/thin.log"
    
    thin_monitoring(w, {:service => "filecache", :tire => tire})
  end
end
