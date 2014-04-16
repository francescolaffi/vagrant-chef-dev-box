node.default['newrelic']['web_server']['service_name'] = 'php-fpm'
include_recipe 'newrelic'
include_recipe 'newrelic::php-agent'

