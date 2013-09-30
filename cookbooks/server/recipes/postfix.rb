node.default['postfix']['main'].merge!({
  'mydestination' => '',
  'inet_interfaces' => 'all',
  'virtual_alias_maps' => 'hash:/etc/postfix/virtual'
})

include_recipe 'postfix'

file '/etc/postfix/virtual' do
  content node['postfix_virtual_map']
  notifies :run, 'execute[postfix-refresh-virtual]', :immediately
end

execute 'postfix-refresh-virtual' do
  command 'postmap /etc/postfix/virtual'
  notifies :reload, 'service[postfix]', :delayed
  action :nothing
end