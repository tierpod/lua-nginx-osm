# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.4"

  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.21"
  # config.vm.network "public_network"

  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provision "shell", inline: <<-SHELL
    yum install -y epel-release
    yum install -y tmux mc git vim lua lua-bitop
  SHELL
end
