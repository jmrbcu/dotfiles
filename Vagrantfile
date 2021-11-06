# -*- mode: ruby -*-
# vi: set ft=ruby :

$version = :unknown
case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    $version = :windows
  when /darwin|mac os/
    $version = :macosx
  when /linux/
    $version = :linux
  when /solaris|bsd/
    $version = :unix
end

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  
  config.vm.define "centos6", primary: true do |centos6|
    centos6.vm.box = "generic/centos6"
    centos6.vm.hostname = "CentOS6"
    centos6.vm.provider "virtualbox" do |vb|
      vb.name = centos6.vm.hostname + "-Dotfiles"
    end
  end

  config.vm.define "debian11" do |debian11|
    debian11.vm.box = "generic/debian11"
    debian11.vm.hostname = "Debian11"
    debian11.vm.provider "virtualbox" do |vb|
      vb.name = debian11.vm.hostname + "-Dotfiles"
    end
  end

  config.vm.synced_folder ".", "/home/vagrant/.dotfiles"
  config.vm.provision "shell", privileged: false, inline: <<-'SCRIPT'
    #!/usr/bin/env bash
    set -e
  SCRIPT
end
