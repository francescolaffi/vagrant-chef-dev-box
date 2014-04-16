
file "#{node['php']['ext_conf_dir']}/99-#{node['admin_host']}.ini" do
  content <<-INI
[HOST=#{node['admin_host']}]
upload_max_filesize = 16M;
post_max_size = 20M;
newrelic.enabled = false
  INI
  notifies :reload, 'service[php-fpm]', :delayed
end

template "#{node['nginx']['dir']}/sites-available/services-admin" do
  source   'nginx-virtual-path.erb'
  variables ({
    'host' => node['admin_host'],
    'paths' => {
      'phpmyadmin' => '/usr/share/phpmyadmin/',
      'xcache' => '/usr/share/xcache/admin/'
    }
  })
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site 'services-admin' do
  enable true
end
