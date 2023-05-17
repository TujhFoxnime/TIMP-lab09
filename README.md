*Устанавлиаем VirtualBox:
*
*sudo apt-get update
*sudo apt-get install virtualbox
*
*Пакеты Vagrant:
*
*curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
*sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release
-cs) main"
*sudo apt-get update && sudo apt-get install vagrant
*
*
*
*Проверим, что вагрант установлен, и терминал выведет версию:
*
*vagrant --version
*
*Создание виртуальной машины в Vagrant
*Для создания виртуальной машины создадим отдельную папку VagrantVM:
*
*mkdir VagrantVM
*cd VagrantVM
*
*Наше web-приложение будет состоять из одного файла, которое будет выводить
информацию о текущей конфигурации PHP index.php:
*
*<?php
*phpinfo();
*
*Проинициализируем вагрант, и автоматически появится Vagrantfile на языке ruby:
*
*vagrant init -m bento/ubuntu-22.04
*
*Содержимое:
*
*# -*- mode: ruby -*-
*# vi: set ft=ruby :
*Vagrant.configure("2") do |config|
*config.vm.box = "bento/ubuntu-22.04"
*end
*
*При создании Vagrantfile мы указали название бокса  bento/ubuntu-20.04 . Бокс это
образ операционной системы, который так же может содержать установленные
программы (LAMP, Python и т.д).
*
*Перед созданием виртуальной машины добавим еще несколько настроек в Vagrantfile:
*
*# -*- mode: ruby -*-
*# vi: set ft=ruby :
*Vagrant.configure("2") do |config|
*# Образ виртуальной машины с Vagrant Cloud
*config.vm.box = "bento/ubuntu-22.04"
*# Настройки виртуальной машины и выбор провайдера
*config.vm.provider "virtualbox" do |vb|
*vb.name = "VagrantVM"
*# Отключаем интерфейс, он не понадобится
*vb.gui = false
*# 2 Гб оперативной памяти
*vb.memory = "2048"
*# Одноядерный процессор
*vb.cpus = 1
*end
*config.vm.hostname = "VagrantVM"
*config.vm.synced_folder ".", "/home/vagrant/code",
*owner: "www-data", group: "www-data"
*# Переброс портов
*config.vm.network "forwarded_port", guest: 80, host: 8000
*config.vm.network "forwarded_port", guest: 3306, host: 33060
*# Команда для настройки сети
*config.vm.network "private_network", ip: "192.168.10.100"
*# Команда, которая выполнится после создания машины
*config.vm.provision "shell", path: "provision.sh"
*end
*
*
*
*
*config.vm.box  — базовый образ. В нашем случае Ubuntu 22.04
*config.vm.provider  — система виртуализации. Доступные провайдеры:
VirtualBox, VMware, Hyper-V, Docker и др.
*config.vm.hostname  — имя хоста.
*config.vm.synced_folder  — синхронизация папок. Первым параметром
передается путь хостовой (основной) машины, вторым параметром передается
путь гостевой (виртуальной машины)
*config.vm.network  — настройки сети. Мы настроили перенаправление портов и
статический ip-адрес, к которому привяжем домен. Доступны и другие
настройки.
*config.vm.provision  — служит для автоматической установки и настройки
программного обеспечения. Мы использовали самый простой способ Shell-
скрипт, также доступны другие: Ansible, Chef, Puppet и др.
*
*Для удобства настройка системы вынесена в отдельный файл  provision.sh . Во
время установки Vagrant запустит его внутри созданной виртуальной машины.
*
*Содержимое файла  provision.sh :
*
*apt-get update
*apt-get -y upgrade
*apt-add-repository ppa:ondrej/php -y
*apt-get update
*apt-get install -y software-properties-common curl zip
*apt-get install -y php7.2-cli php7.2-fpm \
*php7.2-pgsql php7.2-sqlite3 php7.2-gd \
*php7.2-curl php7.2-memcached \
*php7.2-imap php7.2-mysql php7.2-mbstring \
*php7.2-xml php7.2-json php7.2-zip php7.2-bcmath php7.2-soap \
*php7.2-intl php7.2-readline php7.2-ldap
*apt-get install -y nginx
*rm /etc/nginx/sites-enabled/default
*rm /etc/nginx/sites-available/default
*cat > /etc/nginx/sites-available/vagrantvm <<EOF
*server {
*listen 80;
*server_name .vagrantvm.loc;
*root "/home/vagrant/code";
*index index.html index.htm index.php;
*charset utf-8;
*location / {
*try_files \$uri \$uri/ /index.php?\$query_string;
*}
*location = /favicon.ico { access_log off; log_not_found off; }
*location = /robots.txt { access_log off; log_not_found off; }
*access_log off;
*error_log /var/log/nginx/vagrantvm-error.log error;
*location ~ \.php$ {
*fastcgi_split_path_info ^(.+\.php)(/.+)$;
*fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
*fastcgi_index index.php;
*include fastcgi_params;
*fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
*}
*}
*EOF
*ln -s /etc/nginx/sites-available/vagrantvm /etc/nginx/sites-enabled/vagrantvm
*service nginx restart
*
*Создаем виртуальную машину:
*
*vagrant up
*
*(В обход ошибки 404 я воспользовался впном с сайта freeopen vpn)
*
*Проверка статуса виртуальной машины:
*
*vagrant status
*
*Current machine states:
*
*default                   running (virtualbox)
*
*The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

*
*Подключение к виртуальной машине через SSH:
*
*vagrant ssh
*
*Пароль по умолчанию: vagrant. Имя пользователя: vagrant. Потому вводим здесь
пароль: vagrant. И нажимаем клавишу Enter.
*
*Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.4.0-144-generic x86_64)
*
* * Documentation:  https://help.ubuntu.com
* * Management:     https://landscape.canonical.com
* * Support:        https://ubuntu.com/advantage
*
*  System information as of Thu 04 May 2023 07:28:04 PM UTC
*
*  System load:  0.25               Processes:             141
*  Usage of /:   12.0% of 30.34GB   Users logged in:       0
*  Memory usage: 16%                IPv4 address for eth0: 10.0.2.15
*  Swap usage:   0%                 IPv4 address for eth1: 198.128.33.10
*
*Чтобы вернуться из этого режима в нормальный режим командной строки
хостовой ОС, выполняем команду:
*exit
*
*
*Запись ВМ для быстрого запуска в следующий раз:
*
*vagrant snapshot push
*
*==> default: Snapshotting the machine as 'push_1683194634_2345'...
*==> default: Snapshot saved! You can restore the snapshot at any time by
*==> default: using `vagrant snapshot restore`. You can delete it using
*==> default: `vagrant snapshot delete`.
*
*Вывод, записанного снимка:
* 
*vagrant snapshot list
*
*==> default:
*push_1683194634_2345
*
*Завершение сеанса работы с ВМ:
*
*vagrant halt
*
*==> default: Attempting graceful shutdown of VM...







Основные команды Vagrant:

*vagrant up - запустить или создать виртуальную машину
*vagrant reload - перезагрузка виртуальной машины
*vagrant halt  - останавливает виртуальную машину
*vagrant destroy  - удаляет виртуальную машину
*vagrant suspend  - "замораживает" виртуальную машину
*vagrant global-status  - выводит список всех ранее созданных виртуальных машин в хост-системе
*vagrant status - посмотреть статус виртуальной машины
*vagrant ssh  - подключается к виртуальной машине по SSH
*vagrant - список всех доступных команд
