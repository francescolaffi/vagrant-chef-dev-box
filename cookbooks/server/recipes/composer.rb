composer_bin = '/usr/local/bin/composer'
composer_home = '/var/local/composer'
composer_update_stamp = "#{composer_home}/update-stamp"
composer_tools_dir = '/opt/composer-tools'

directory composer_home do
  recursive true
end

file '/etc/profile.d/composer.sh' do
  content <<-SH
export COMPOSER_HOME=#{composer_home}
export PATH=#{composer_tools_dir}/bin:$PATH
  SH
end
ENV['COMPOSER_HOME'] = composer_home
ENV['PATH'] = "#{composer_tools_dir}/bin:#{ENV['PATH']}"

file composer_update_stamp do
  action :nothing
end

remote_file composer_bin do
  source 'https://getcomposer.org/composer.phar'
  mode   00755
  backup false
  action :create_if_missing
  notifies :touch, "file[#{composer_update_stamp}]", :immediately
end

execute "#{composer_bin} self-update" do
  not_if do
    ::File.exist?(composer_update_stamp) && 
    ::File.mtime(composer_update_stamp) > Time.now - 86400 # 1 day
  end
  notifies :touch, "file[#{composer_update_stamp}]", :immediately
end

directory composer_tools_dir do
  recursive true
end

execute 'composer-tools setup composer.json' do
  cwd composer_tools_dir
  command <<-EOH
    #{composer_bin} init --stability dev --no-interaction
    #{composer_bin} config bin-dir bin
    #{composer_bin} config vendor-dir vendor
  EOH
  creates "#{composer_tools_dir}/composer.json"
end

execute 'composer-tools install/update' do
  cwd composer_tools_dir
  command <<-EOH
    #{composer_bin} require d11wtq/boris=@stable && \
    #{composer_bin} require wp-cli/wp-cli=@stable && \
    #{composer_bin} update && \
    touch #{composer_tools_dir}/update-stamp
  EOH
  not_if do
    ::File.exist?("#{composer_tools_dir}/update-stamp") && 
    ::File.mtime("#{composer_tools_dir}/update-stamp") > Time.now - 86400 # 1 day
  end
end
