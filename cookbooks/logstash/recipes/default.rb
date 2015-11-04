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

execute 'apt-get update'

package 'logstash' do
  action :install
  version '1:2.0.0-1'
end

service 'logstash' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

template '/etc/logstash/conf.d/logstash-simple.conf' do
  source 'conf/logstash-simple.erb'
  notifies :restart, 'service[logstash]', :immediately
end