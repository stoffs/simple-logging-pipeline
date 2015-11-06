include_recipe 'java::openjdk'

package 'wget' do
  action :install
end

execute 'Download and install the public signing key' do
  command 'wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -'
end

execute 'Add the repository definition' do
  command "echo 'deb http://packages.elasticsearch.org/logstash/2.0/debian stable main' | sudo tee -a /etc/apt/sources.list"
end

directory '/etc/pki/tls/certs/' do
  action :create
  recursive true
end

directory '/etc/pki/tls/private' do
  action :create
  recursive true
end

execute 'apt-get update'

package 'logstash' do
  action :install
  version '1:2.0.0-1'
end

service 'logstash' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

cookbook_file '/etc/pki/tls/certs/logstash-forwarder.crt' do
  source 'tls/certs/logstash-forwarder.crt'
end

cookbook_file '/etc/pki/tls/private/logstash-forwarder.key' do
  source 'tls/private/logstash-forwarder.key'
end

template '/etc/logstash/conf.d/01-lumberjack-input.conf' do
  source 'conf/01-lumberjack-input.conf.erb'
  notifies :restart, 'service[logstash]'
end

template '/etc/logstash/conf.d/10-syslog.conf' do
  source 'conf/10-syslog.conf.erb'
  notifies :restart, 'service[logstash]'
end

template '/etc/logstash/conf.d/30-lumberjack-output.conf' do
  source 'conf/30-lumberjack-output.conf.erb'
  notifies :restart, 'service[logstash]'
end

#template '/etc/logstash/conf.d/logstash-simple.conf' do
#  source 'conf/logstash-simple.erb'
#  notifies :restart, 'service[logstash]', :immediately
#end