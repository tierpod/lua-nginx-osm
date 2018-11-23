# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"

  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.21"
  # config.vm.network "public_network"

  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provision "shell", path: "misc/centos7-install.sh"
end
