#
# Author:: Brian Olsen (<brian@maven-group.org>)
# Copyright:: Copyright (c) 2012, Maven-Group
# License:: Apache License, Version 2.0
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
default['sqlanywhere']['data_dir'] = '/var/local/sqlanywhere12'
default['sqlanywhere']['server_name'] = 'default'
default['sqlanywhere']['service_name'] = 'sa12'
default['sqlanywhere']['user'] = 'sa12'
default['sqlanywhere']['group'] = 'sa12'
if node['languages']['ruby']['host_cpu'] == 'x86_64'
  default['sqlanywhere']['bin_dir'] = 'bin64'
else
  default['sqlanywhere']['bin_dir'] = 'bin32'
end