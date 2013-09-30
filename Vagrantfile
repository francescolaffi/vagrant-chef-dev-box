# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
private_config = YAML.load_file('private-config.yml')

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = private_config['hostname']

  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.provider :digital_ocean do |provider, override|
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'

    private_config['ssh'].each do |k,v|
      override.ssh.send(:"#{k}=", v)
    end
    
    private_config['digital_ocean'].each do |k,v|
      provider.send(:"#{k}=", v)
    end
  end

  config.vm.provider :virtualbox do |vb, override|
    # enable cache with vagrant-cachier
    if defined?(VagrantPlugins::Cachier)
      override.cache.auto_detect = true
      override.cache.enable :chef
      override.cache.enable_nfs  = (RUBY_PLATFORM =~ /linux/ or RUBY_PLATFORM =~ /darwin/)
    end
    # change memory
    vb.customize ['modifyvm', :id, '--memory', '512']
  end

  # update guest chef with vagrant-omnibus
  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    # $ CHEF_LOG_LEVEL=debug vagrant <provision or up>
    chef.log_level = ENV['CHEF_LOG_LEVEL'] || 'info'

    chef.data_bags_path = 'data_bags'

    chef.add_recipe 'server'
    chef.add_recipe 'sites'
  
    chef.json = private_config['chef']
  end
end
