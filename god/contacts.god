God::Contacts::Email.defaults do |d|
  d.from_email = 'god@hoccer.com'
  d.from_name = 'God'
  d.delivery_method = :smtp
  d.server_auth = :plain
  d.server_port = "25"
  d.server_host = "smtprelaypool.ispgateway.de"
  d.server_domain = "smtprelaypool.ispgateway.de"
  d.server_user = "god@hoccer.com"
  d.server_password = "eeoIIkww"
end

God.contact(:email) do |c|
  c.name = 'rodja'
  c.group = 'developers'
  c.to_email = 'rodja@hoccer.com'
end

God.contact(:email) do |c|
  c.name = 'john'
  c.group = 'developers'
  c.to_email = 'john@hoccer.com'
end

God.contact(:email) do |c|
  c.name = 'robert'
  c.group = 'developers'
  c.to_email = 'robert@hoccer.com'
end

God.contact(:email) do |c|
  c.name = 'god'
  c.to_email = 'god@hoccer.com'
end

@developer_info = {:contacts => ['god', 'developers'], :priority => 1, :category => "INFO"}
@developer_warn = {:contacts => ['god', 'developers'], :priority => 2, :category => "WARN"}
@developer_alert = {:contacts => ['god', 'developers'], :priority => 3, :category => "ALERT"}

