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
actions :create, :drop, :grant

attribute :connection, :required => true
attribute :database_name, :kind_of => String, :required=>true
attribute :username, :kind_of => String, :name_attribute => true
attribute :password, :kind_of => String, :required => true
attribute :table, :kind_of => String
attribute :privileges, :kind_of => Array, :default=>[:all]

def initialize(*args)
  super
  @action = :create
end
