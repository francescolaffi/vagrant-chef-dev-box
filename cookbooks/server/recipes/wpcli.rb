wpcli_dir = '/usr/local/wp-cli'
wpcli_update_stamp = "#{composer_home}/update-stamp"

directory wpcli_dir do
  recursive true
end

execute 'setup wp-cli composer' do
  cwd wpcli_dir
  command <<-EOH
    composer init --stability dev --no-interaction;
    composer config bin-dir bin;
    composer config vendor-dir vendor;
  EOH
  creates "#{wpcli_dir}/composer.json"
end

execute 'install/update wp-cli and boris' do
  cwd wpcli_dir
  command <<-EOH
    composer require 'wp-cli/wp-cli=@stable';
    composer require 'd11wtq/boris=@stable';
    composer update;
  EOH
end

link '/usr/local/bin/wp' do
  to "#{wpcli_dir}/bin/wp"
end