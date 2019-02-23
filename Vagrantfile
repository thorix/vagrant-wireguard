# -*- mode: ruby -*-
# vi: set ft=ruby :

# Parse options https://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-vagrantfile
options = {}
options[:backup_src]  = ENV['BACKUP_SRC']
options[:backup_dest] = ENV['BACKUP_DEST']
options[:backup_user] = ENV['BACKUP_USER']
options[:ssh_key]     = ENV['SSH_KEY']

# Use libvirt
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

# Overwrite host locale in ssh session
ENV["LC_ALL"] = "en_US.UTF-8"

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 2.2.0"

Vagrant.configure(2) do |config|
  config.vm.box = "debian/stretch64"
  config.vm.hostname = "gauge"
  config.vm.network "public_network",
    :dev => "br0",
    :mode => "bridge",
    :type => "dhcp",
    :network_name => "public-network"

  config.vm.synced_folder options[:backup_src], options[:backup_dest], type: 'nfs'
  config.vm.synced_folder './', '/vagrant', type: 'rsync'

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "qemu"
    libvirt.memory = 512
  #  libvirt.host = "gauge"
  end
end
