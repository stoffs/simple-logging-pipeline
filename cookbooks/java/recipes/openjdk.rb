execute 'apt-get update'

#package 'python-software-properties' do
#  action :install
#end

package 'openjdk-7-jdk' do
  version '7u85-2.6.1-5ubuntu0.14.04.1'
  action :install
end
