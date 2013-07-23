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

require File.join(File.dirname(__FILE__), 'provider_sqlanywhere_database')

class Chef
  class Provider
    class SqlanywhereDatabaseUser < Chef::Provider::SqlanywhereDatabase

      def load_current_resource
        @current_resource = Chef::Resource::DatabaseUser.new(@new_resource.name)
        @current_resource.username(@new_resource.name)
        @current_resource
      end

      def action_create
        unless exists?
          Chef::Application.fatal!('Please provide a database_name, SQLAnywhere does not support global GRANT statements.') unless @new_resource.database_name
          query("CREATE USER \"#{@new_resource.username}\" IDENTIFIED BY '#{@new_resource.password}'", @new_resource.connection[:database] || @new_resource.database_name)
          #query("GRANT CONNECT TO #{@new_resource.username} IDENTIFIED BY '#{@new_resource.password}'", @new_resource.connection[:database] || @new_resource.database_name)
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_drop
        if exists?
          Chef::Application.fatal!('Please provide a database_name, SQLAnywhere does not support global GRANT statements.') unless @new_resource.database_name
          query("DROP USER \"#{@new_resource.username}\"", @new_resource.connection[:database] || @new_resource.database_name)
          #query("REVOKE CONNECT FROM #{@new_resource.username}", @new_resource.connection[:database] || @new_resource.database_name)
          @new_resource.updated_by_last_action(true)
        end
      end

      def action_grant
        if @new_resource.password
          action_create
        end
        Chef::Application.fatal!('Please provide a database_name, SQL Server does not support global GRANT statements.') unless @new_resource.database_name
        tbl = @new_resource.table.nil? ? "" : "ON #{@new_resource.table} "
        grant_statement = "GRANT #{@new_resource.privileges.join(', ')} #{tbl}TO #{@new_resource.username}"
        Chef::Log.info("#{@new_resource} granting access with statement [#{grant_statement}]")
        query(grant_statement, @new_resource.connection[:database] || @new_resource.database_name)
        @new_resource.updated_by_last_action(true)
      end

      private
      def exists?
        command('userexists', @new_resource.username, @new_resource.connection[:database] || @new_resource.database_name) == 0
      end
    end
  end
end
