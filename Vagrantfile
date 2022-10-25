# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.synced_folder ".", "/home/vagrant/.dotfiles"
  config.vbguest.auto_update = true

  # three development boxes: CentOS 6, Debian 10 and Debian 11
  config.vm.define "centos6", primary: true do |centos6|
    centos6.vm.box = "generic/centos6"
    centos6.vm.hostname = "DotFiles-CentOS6"
    centos6.vm.provider "virtualbox" do |vb|
      vb.name = centos6.vm.hostname
    end
  end

  config.vm.define "debian11" do |debian11|
    debian11.vm.box = "generic/debian11"
    debian11.vm.hostname = "DotFiles-Debian11"
    debian11.vm.provider "virtualbox" do |vb|
      vb.name = debian11.vm.hostname
    end
  end

  config.vm.provision "shell", privileged: false, keep_color: true, inline: <<-'SCRIPT'
  #!/usr/bin/env bash
  if command -v apt-get &>/dev/null; then
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git sudo
  elif command -v yum &>/dev/null; then
    sudo yum -y update
    sudo yum -y install git sudo
  fi
  SCRIPT
end
