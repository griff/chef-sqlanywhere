#require File.expand_path('../helpers', __FILE__)

describe 'sqlanywhere::server' do

  #include Helpers::SqlAnywhere

  it 'has a secure utility DBA password' do
    node["sqlanywhere"]["server_utility_password"].length.must_be_close_to(20, 8)
  end
  it 'has a data directory' do
    directory(node['sqlanywhere']["data_dir"]).must_exist.with(:owner, 'sa12').and(:group, 'sa12')
  end
  it 'runs as a daemon' do
    service(node['sqlanywhere']['service_name']).must_be_running
  end
end
