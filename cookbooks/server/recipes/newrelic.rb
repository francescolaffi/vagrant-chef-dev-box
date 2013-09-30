node.default['newrelic']['web_server']['service_name'] = 'php-fpm'
node.default['newrelic']['application_monitoring']['enabled'] = false
include_recipe 'newrelic'
include_recipe 'newrelic::php-agent'
