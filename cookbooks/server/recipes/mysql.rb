node.default['mysql'].merge!({
  'remove_anonymous_users' => true,
  'remove_test_database' => true,
  'allow_remote_root' => false,
})


include_recipe 'mysql::percona_repo'

file 'testfile' do
  path '/tmp/test1'
  content 'foobar'  
end

include_recipe 'mysql::server'
resources(:template => "#{node['mysql']['conf_dir']}/my.cnf").cookbook cookbook_name.to_s 


node.set['phpmyadmin']['webserver'] = false

include_recipe 'phpmyadmin'