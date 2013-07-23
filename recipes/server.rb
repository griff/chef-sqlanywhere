#
# Author:: Brian Olsen (<brian@maven-group.org>)
# Cookbook Name:: sqlanywhere
# Recipe:: server
#
# Copyright 2012, Maven-Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "sqlanywhere::client"

# generate password
if Chef::Config[:solo]
  missing_attrs = %w{
    server_utility_password
  }.select do |attr|
    node['sqlanywhere'][attr].nil?
  end.map { |attr| "node['sqlanywhere']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/griff/sqlanywhere#chef-solo-note"
      ].join(' '))
  end
else
  node.set_unless['sqlanywhere']['server_utility_password'] = secure_password
  node.save
end

sa12_install = node['sqlanywhere']["install_dir"]
sa12_home = node['sqlanywhere']["data_dir"]
utility_dba_password = node['sqlanywhere']["server_utility_password"]
server_name = node['sqlanywhere']["server_name"]
bin_dir = node['sqlanywhere']['bin_dir']

user node['sqlanywhere']['user'] do
  comment "SQLAnywhere 12 user"
  system true
  shell "/bin/false"
  home sa12_home
end

directory sa12_home do
  owner node['sqlanywhere']['user']
  group node['sqlanywhere']['user']
  mode "0755"
  action :create
end

#bash "create test database" do
#  not_if {File.exists?("#{sa12_home}/test.db")}
#  user "sa12"
#  cwd sa12_home
#  code <<-EOH
#  . #{sa12_install}/bin32/sa_config.sh
#  dbinit test.db
#  EOH
#end

template "/etc/init.d/#{node['sqlanywhere']['service_name']}" do
  source "init.sh.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, "service[#{node['sqlanywhere']['service_name']}]"
end


template "/etc/init/#{node['sqlanywhere']['service_name']}.conf" do
  source "upstart.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[#{node['sqlanywhere']['service_name']}]"
end

bash "encode utility password" do
  user node['sqlanywhere']['user']
  cwd sa12_home
  code <<-EOH
  set -o errexit
  . #{sa12_install}/#{bin_dir}/sa_config.sh
  echo "#{utility_dba_password}" > util_db_pwd.cfg
  dbfhide util_db_pwd.cfg util_db_pwd_hide.cfg 
  rm util_db_pwd.cfg
  EOH
  creates "#{sa12_home}/util_db_pwd_hide.cfg"
end

template "#{sa12_install}/dbsrv.sh" do
  source "dbsrv.sh.erb"
  owner node['sqlanywhere']['user']
  group node['sqlanywhere']['user']
  mode 0744
end

service node['sqlanywhere']['service_name'] do
  action :enable
end

service node['sqlanywhere']['service_name'] do
  action :start
end
