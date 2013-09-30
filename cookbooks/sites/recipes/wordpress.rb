sites_owner = sites_group = 'www-data'

data_bag('wordpress').each do |id|
  site = data_bag_item('wordpress', id).to_hash
  site['name'] ||= site['id']
  site['host'] ||= site['name']
  site['dir']  ||= "/srv/www/#{site['name']}"

  Chef::Log.info(site.inspect)

  %W(#{site['dir']} #{site['dir']}/public #{site['dir']}/logs)
  .each do |dir|
    directory dir do
      owner sites_owner
      group sites_group
      mode 02770
    end
  end

  file "#{site['dir']}/nginx.conf" do
    owner sites_owner
    group sites_group
    mode 00660
    action :create_if_missing
  end

  file "#{node['php']['ext_conf_dir']}/99-#{site['name']}.ini" do
    content <<-INI
[HOST=#{site['host']}]
open_basedir = #{site['dir']}:/tmp;
disable_functions = system,shell_exec,passthru,exec,popen,proc_open, pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority;
upload_max_filesize = 16M;
post_max_size = 20M;
newrelic.enabled = true
newrelic.appname = "#{site['name']}"
    INI
    notifies :reload, 'service[php-fpm]', :delayed
  end

  template "#{node['nginx']['dir']}/sites-available/#{site['name']}" do
    source   'nginx-wordpress.erb'
    variables site
    notifies :reload, 'service[nginx]', :delayed
  end

  nginx_site site['name'] do
    enable true
  end
end