node.default['nginx']['worker_processes'] = 1
node.default['nginx']['default_site_enabled'] = false

apt_repository 'nginx' do
  uri 'http://ppa.launchpad.net/nginx/stable/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'C300EE8C'
end

include_recipe 'nginx'
# package('nginx').action(:upgrade)

file "#{node['nginx']['dir']}/sites-available/default-deny" do
  content <<-CONF
server {
  listen 80 default_server;
  server_name _;
  deny all;
}
  CONF
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site 'default-deny' do
  enable true
end