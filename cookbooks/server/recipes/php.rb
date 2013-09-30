require 'digest/md5'

node.set['php-fpm'] = {
  'pools' => ['www'],
  # 'log_level' => 'debug',
  'pool' => {
    'www' => {
      'process_manager' => 'static',
      'max_children' => 4,
      # 'min_spare_servers' => 1,
      # 'max_spare_servers' => 2,
      # 'start_servers' => 2
    }
  }
}

apt_repository 'php5' do
  uri 'http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
end

include_recipe 'php'

node['php']['packages'].concat(%w(
    php5-curl php5-mysql php5-sqlite php5-intl
    php5-gd php5-xmlrpc php5-xcache php5-mcrypt
  )).each{|pkg| package(pkg)} #.action(:upgrade)}

include_recipe 'php-fpm'

file "#{node['php']['ext_conf_dir']}/50-timezone.ini" do
  owner    'root'
  group    'root'
  mode     00644
  content  'date.timezone = UTC'
  action   :create
  notifies :reload, 'service[php-fpm]', :delayed
end

file "#{node['php']['ext_conf_dir']}/50-caching.ini" do
  owner    'root'
  group    'root'
  mode     00644
  content  <<-INI
xcache.size = 64M
xcache.var_size = 16M

[xcache.admin]
xcache.admin.user = "xcache"
xcache.admin.pass = "#{Digest::MD5.hexdigest(node['xcache_pass'])}"
  INI
  action   :create
  notifies :reload, 'service[php-fpm]', :delayed
end