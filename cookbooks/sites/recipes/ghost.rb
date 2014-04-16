sites_owner = sites_group = 'www-data'

data_bag('ghost').each do |id|
  site = data_bag_item('ghost', id).to_hash
  site['name'] ||= site['id']
  site['host'] ||= site['name']
  site['dir']  ||= "/srv/www/#{site['name']}"
  site['node_env'] ||= 'production'
  site['socket']   ||= "#{site['dir']}/nodejs.sock"

  %W(#{site['dir']} #{site['dir']}/logs)
  .each do |dir|
    directory dir do
      owner sites_owner
      group sites_group
      mode 02770
    end
  end

  service_name = "nodejs-forever-#{site['name']}"

  template "/etc/init/#{service_name}.conf" do
    source   'upstart-forever.erb'
    variables ({
        :dir => site['dir'],
        :script => 'index.js',
        :node_env => site['node_env'],
        :user => sites_owner,
        :group => sites_group,
        :logs => {
          :forever => "#{site['dir']}/logs/forever.log",
          :out => "#{site['dir']}/logs/node-out.log",
          :err => "#{site['dir']}/logs/node-err.log"
        }
      })
    notifies :restart, "service[#{service_name}]", :delayed
  end

  service service_name do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true
    action :start
  end

  template "#{node['nginx']['dir']}/sites-available/#{site['name']}" do
    source   'nginx-ghost.erb'
    variables site
    notifies :reload, 'service[nginx]', :delayed
  end

  nginx_site site['name'] do
    enable true
  end
end