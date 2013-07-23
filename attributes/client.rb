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
default['sqlanywhere']['install_dir'] = '/usr/local/sqlanywhere12'
if node['languages']['ruby']['host_cpu'] == 'x86_64'
  default['sqlanywhere']['packages'] = %w{sqlany64 admintools samon in_memory}
else
  default['sqlanywhere']['packages'] = %w{sqlany32 admintools samon in_memory}
end
default['sqlanywhere']['patch_for_silent'] = false
default['sqlanywhere']['cache_dir'] = '/var/cache/sqlanywhere12'
