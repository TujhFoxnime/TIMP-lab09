# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
config.vm.box = "bento/ubuntu-22.04"
# Настройки виртуальной машины и выбор провайдера
config.vm.provider "virtualbox" do |vb|
vb.name = "VagrantVM"
# Отключаем интерфейс, он не понадобится
vb.gui = false
# 2 Гб оперативной памяти
vb.memory = "2048"
# Одноядерный процессор
vb.cpus = 1
end

config.vm.hostname = "VagrantVM"

config.vm.synced_folder ".", "/home/vagrant/code", 
owner: "www-data", group: "www-data"
# Переброс портов
config.vm.network "forwarded_port", guest: 80, host: 8000
config.vm.network "forwarded_port", guest: 3306, host: 33060
# Команда для настройки сети
config.vm.network "public_network"
# Команда, которая выполнится после создания машины
config.vm.provision "shell", inline: "provision.sh", privileged: true
config.ssh.extra_args = "-tt"
end
