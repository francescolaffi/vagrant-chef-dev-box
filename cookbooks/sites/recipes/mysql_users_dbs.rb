include_recipe 'database::mysql'
mysql_connection = {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}

dbs = []

data_bag('mysql').each do |id|
  user = data_bag_item('mysql', id).to_hash
  user['dbs'] ||= {}

  mysql_database_user user['id'] do
    connection mysql_connection
    password user['password']
    host user['host']
    action :create
  end

  user['dbs'].each do |dbname, dbinfo|
    dbs.push(dbname)
    mysql_database_user "grant on #{dbname} to #{user['id']}" do
      connection mysql_connection
      username user['id']
      password user['password']
      database_name dbname
      privileges dbinfo['privileges']
      host user['host']
      action :grant
    end
  end
end

dbs.uniq.each do |db|
  mysql_database db do
    connection mysql_connection
    action :create
  end
end