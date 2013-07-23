#
# Author:: Brian Olsen (<brian@maven-group.org>)
# Cookbook Name:: sqlanywhere
# Recipe:: client
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

Chef::Application.fatal!("Missing sqlanywhere key") unless node['sqlanywhere'].attribute?("key")
key = node['sqlanywhere']["key"]
Chef::Application.fatal!('Empty sqlanywhere key') if key.nil? || key !~ /\S/

unless node['sqlanywhere']['url']
  Chef::Application.fatal!("You must provide an url with the location of the redmine backup!")
end
  
sa12_install = node['sqlanywhere']["install_dir"]
packages = node['sqlanywhere']["packages"]
local = "#{node['sqlanywhere']['cache_dir']}/ga1201.tar.gz"
remote = node['sqlanywhere']['url']

directory node['sqlanywhere']['cache_dir'] do
  recursive true
  mode "0755"
end

if remote.downcase.start_with?('http:')
  remote_file local do
    source remote
    mode   0660
    action :nothing
    notifies :run, "bash[sqlanywhere unpack]", :immediately 
  end

  http_request "HEAD #{remote}" do
    message ""
    url remote
    action :head
    if File.exists?(local)
      headers "If-Modified-Since" => File.mtime(local).httpdate
    end
    notifies :create, resources(:remote_file => local), :immediately
  end
else
  cookbook_file local do
    source remote
    mode   0660
    notifies :run, "bash[sqlanywhere unpack]", :immediately 
  end
end

bash "sqlanywhere unpack" do
  cwd node['sqlanywhere']['cache_dir']
  code <<-EOH
  set -o errexit
  rm -rf ga1201
  tar -zxf ga1201.tar.gz
  EOH
  action :nothing
end

if node['sqlanywhere']['patch_for_silent']
  package "patch"
  
  cookbook_file "#{node['sqlanywhere']['cache_dir']}/patch_for_silent.patch" do
    source "allow-silent.patch"
    mode "0644"
  end

  bash "patch" do
    cwd "#{node['sqlanywhere']['cache_dir']}/ga1201"
    code <<-EOH
    set -o errexit
    patch -p0 < ../patch_for_silent.patch
    touch patch_for_silent.patched
    EOH
    creates "#{node['sqlanywhere']['cache_dir']}/ga1201/patch_for_silent.patched"
  end
end

bash "install" do
  not_if {File.exists?(sa12_install)}
  cwd "#{node['sqlanywhere']['cache_dir']}/ga1201"
  code <<-EOH
  set -o errexit
  ./setup -nogui -ss -regkey #{key} -I_accept_the_license_agreement -d "#{sa12_install}" -type CREATE -install #{packages.join(',')}
  EOH
end

cookbook_file "#{sa12_install}/driver.rb" do
  source "driver.rb"
  mode "0755"
end

cookbook_file "#{sa12_install}/driver.sh" do
  source "driver.sh"
  mode "0755"
end
