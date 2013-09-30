include_recipe 'server'
include_recipe 'sites::services_admin'
include_recipe 'sites::mysql_users_dbs'

directory '/srv/www' do
  owner 'root'
  group 'www-data'
  mode 02755
  recursive true
end

www_users = []
current_user = ENV['SUDO_USER'] || ENV['USER']
www_users << current_user if current_user != 'root'

group 'www-data' do
  action :modify
  members www_users
  append true
end

include_recipe 'sites::wordpress'