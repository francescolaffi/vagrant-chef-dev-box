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