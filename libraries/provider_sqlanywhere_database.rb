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

require 'chef/provider'

class Chef
  class Provider
    class SqlanywhereDatabase < Chef::Provider
      include Chef::Mixin::ShellOut

      def load_current_resource
        @current_resource = Chef::Resource::Database.new(@new_resource.name)
        @current_resource.database_name(@new_resource.database_name)
        @current_resource
      end

      def action_create
        unless exists?
          Chef::Log.debug("#{@new_resource}: Creating database #{new_resource.database_name}")
          opts = []
          opts << "COLLATION '#{new_resource.collation}'" if new_resource.collation
          opts << "ENCODING '#{new_resource.encoding}'" if new_resource.encoding
          query("CREATE DATABASE '#{new_resource.database_name}' #{opts.join(' ')} DBA PASSWORD '#{dba_password}'")
          query("START DATABASE '#{new_resource.database_name}.db' AUTOSTOP OFF")
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_drop
        if exists?
          Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.database_name}")
          query("DROP DATABASE '#{new_resource.database_name}'")
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_query
        if exists?
          Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql}]")
          query(@new_resource.sql, @new_resource.connection[:database] || @new_resource.database_name)
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_query_file
        if exists?
          Chef::Log.debug("#{@new_resource}: Performing query in file [#{new_resource.sql_file}]")
          query_file(@new_resource.sql_file, @new_resource.connection[:database] || @new_resource.database_name)
          @new_resource.updated_by_last_action(true)
        end
      end

      private
      def dba_password
        @new_resource.dba_password || password
      end
      
      def password
        @new_resource.connection[:password] || node['sqlanywhere']['server']['utility_password']
      end

      def exists?
        command('dbexists', @new_resource.database_name) == 0
      end
      
      def query(sql, database=nil)
        command('query', sql, database)
      end

      def query_file(sql_file, database=nil)
        command('queryfile', sql_file, database)
      end
      
      def command(cmd, arg, database=nil)
        env = {
          'database'=> database || @new_resource.connection[:database],
          'host' => @new_resource.connection[:host],
          'port' => (@new_resource.connection[:port] || 2638).to_s,
          'username' => @new_resource.connection[:username] || "dba",
          'password' => password,
          'server_name' => @new_resource.connection[:server_name] || node['sqlanywhere']['server_name']
        }
        sa12_install = node['sqlanywhere']['install_dir']
        opts = {}
        opts[:timeout] = 3600
        opts[:environment] = env
        #opts[:user] = @new_resource.user if @new_resource.user
        #opts[:group] = @new_resource.group if @new_resource.group
        opts[:cwd] = sa12_install
        #opts[:umask] = @new_resource.umask if @new_resource.umask
        opts[:returns] = [0,2]
        #opts[:command_log_level] = :info
        result = shell_out!("#{sa12_install}/driver.sh", cmd, arg, opts)
        @new_resource.updated_by_last_action(true)
        Chef::Log.info("#{@new_resource} ran successfully")
        result.exitstatus
      end
    end
  end
end