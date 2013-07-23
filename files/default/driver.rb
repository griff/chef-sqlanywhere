#!/usr/bin/env ruby
require 'rubygems'
require 'sqlanywhere'

module Sqlanywhere
  module SA
    def self.api
      @@api ||= begin
        ret = ::SQLAnywhere::SQLAnywhereInterface.new
        result = ::SQLAnywhere::API.sqlany_initialize_interface( ret )
        if result == 0 
          raise LoadError, "Could not load SQLAnywhere DLL"
        end
        result = ret.sqlany_init
        if result == 0 
          raise LoadError, "Could not initialize SQLAnywhere DLL"
        end
        ret
      end
    end

    def self.free_api
      if @@api
        @@api.sqlany_fini
        ::SQLAnywhere::API.sqlany_finalize_interface( @@api );
        @@api = nil
      end
    end
  end
  
  class ResultRow
    def initialize(rs, data)
      @rs = rs
      @data = data
    end
    
    def [](key)
      if key.is_a?(String)
        @data[column_idx[key]]
      else
        @data[key]
      end
    end
    
    def column_idx(key)
      @column_idx ||= begin
        val={}
        @rs.columns.each_with_index{|c, i| val[c] = i}
        val
      end
    end
  end
  
  class ResultSet
    include Enumerable
    
    attr_reader :connection
    
    def initialize(conn, stmt)
      @stmt = stmt
      @connection = conn
    end
    
    def each
      while true
        break if SA.api.sqlany_fetch_next( @stmt ) == 0
        data = (0...columns.size).map do |idx|
          rc, value = SA.api.sqlany_get_column( @stmt, idx )
          if rc == 0
            code, msg = connection.error
            raise "Error getting column #{idx}; Code=#{code} Message=#{msg}"
          end
          value
        end
        yield ResultRow.new(self, data)
      end
    end
    
    def size
      @num_rows ||= begin
        c = 0
        each {|d| c += 1}
        c
      end
      #@num_rows ||= SA.api.sqlany_num_rows( @stmt )
    end

    def columns
      @columns ||= begin
        num_cols = SA.api.sqlany_num_cols( @stmt )
        if num_cols < 0
          code, msg = connection.error
          raise "Error getting column count; Code=#{code} Message=#{msg}"
        end
        (0...num_cols).map do |idx|
          ret, i, name = SA.api.sqlany_get_column_info(@stmt, idx)
          if ret == 0
            code, msg = connection.error
            raise "Error getting column info #{idx}; Code=#{code} Message=#{msg}"
          end
          name
        end
      end
    end
    
    def close
      SA.api.sqlany_free_stmt( @stmt )
    end
  end
  
  class Connection
    attr_reader :host, :port, :database, :user, :password, :server_name
    def initialize(options={})
      @host = options[:host] || 'localhost'
      @port = options[:port]
      @database = options[:database] || 'utility_db'
      @user = options[:user] || 'dba'
      @password = options[:password] || 'sql'
      @server_name = options[:server_name] || 'default'
      @connected = false
    end
    
    def connect_string
      ip = port.nil? ? host : "#{host}:#{port}"
      {
        'ENG' => server_name,
        'DBN' => database,
        'UID' => user,
        'PWD' => password,
        'CommLinks' => "tcpip(HOST=#{ip})"
      }.map{|e,v| "#{e}=#{v}"}.join(';')
    end
    
    def error
      SA.api.sqlany_error( @conn )
    end
    
    def connect
      return if @connected
      @conn = SA.api.sqlany_new_connection
      result = SA.api.sqlany_connect( @conn, connect_string )
      if result == 0
        code, msg = self.error
        raise "Could not connect to SQLAnywhere database; Code=#{code} Message=#{msg}"
      end
      @connected = true
    end
    
    def query(sql)
      connect
      result = SA.api.sqlany_execute_immediate(@conn, sql)
      if result == 0
        code, msg = self.error
        sql = sql[0..100]
        raise "Problem Code=#{code} Message=#{msg} when executing statement '#{sql}': "
      end
    end
    
    def execute(sql)
      connect
      stmt = SA.api.sqlany_execute_direct(@conn, sql)
      unless stmt
        code, msg = self.error
        raise "Problem Code=#{code} Message=#{msg} when executing statement '#{sql}': "
      end
        
      ret = ResultSet.new(self, stmt)
      return ret unless block_given?
      begin
        yield ret
      ensure
        ret.close
      end
    end

    def close
      if @conn
        SA.api.sqlany_disconnect(@conn) if @connected
        SA.api.sqlany_free_connection(@conn)
      end
      SA.free_api
    end
  end
end

def db
  @db ||= begin
    dbname = ENV['database'] || 'utility_db'
    host = ENV['host']
    port = ENV['port'] || 2638
    user = ENV['username'] || "dba"
    server_name = ENV['server_name'] || 'default'
    password = ENV['password']
    
    puts "Database: '#{dbname}'"
    puts "Host: '#{host}'"
    puts "Port: '#{port}'"
    puts "Username: '#{user}'"
    puts "Server Name: '#{server_name}'"
    puts "Password: '#{'*'*(password || '').size}'"
    
    ::Sqlanywhere::Connection.new(
      :host => host,
      :port => port,
      :database => dbname,
      :user => user,
      :password => password,
      :server_name => server_name
    )
  end
end

def close
  @db.close rescue nil
  @db = nil
end

ret = 0
if ARGV[0] == 'userexists'
  username = ARGV[1]
  begin
    unless db.execute("select user_id from sysuser where user_name='#{username}'"){|rst| rst.size > 0 }
      ret = 2
    end
  ensure
    close
  end
elsif ARGV[0] == 'dbexists'
  database_name = ARGV[1]
  begin
    exists = false
    idx = 0
    while !exists
      name = db.execute("select db_property('Name',#{idx})") {|res| res.first[0] }
      break unless name
      exists = name =~ /^#{database_name}$/i
      idx += 1
    end
      
    #db.execute("select db_property('Name',0)") do |result|
    #  result.each do |row|
    #    if row['Alias'] =~ /^#{database_name}$/i
    #      exists = true
    #      break
    #    end
    #  end
    #end
    ret = 2 unless exists
  ensure
    close
  end
elsif ARGV[0] == 'queryfile'
  query = File.read(ARGV[1]).split(/^go/)
  begin
    query.each do |q|
      next if q.strip.size == 0
      db.query(q)
    end
  ensure
    close
  end
elsif ARGV[0] == 'select'
  query = ARGV[1]
  begin
    unless db.execute(query){|rst| rst.size > 0 }
      ret = 2
    end
  ensure
    close
  end
else
  query = ARGV[1]
  begin
    db.query(query)
  ensure
    close
  end
end

exit ret