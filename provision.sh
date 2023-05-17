apt-get update
apt-get -y upgrade

apt-add-repository ppa:ondrej/php -y	

apt-get update

apt-get install -y software-properties-common curl zip

apt-get install -y php7.2-cli php7.2-fpm \
php7.2-pgsql php7.2-sqlite3 php7.2-gd \
php7.2-curl php7.2-memcached \
php7.2-imap php7.2-mysql php7.2-mbstring \
php7.2-xml php7.2-json php7.2-zip php7.2-bcmath php7.2-soap \
php7.2-intl php7.2-readline php7.2-ldap

apt-get install -y nginx

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

cat > /etc/nginx/sites-available/vagrantvm <<EOF
server {
	listen 80;
	server_name .vagrantvm.loc;
	root "/home/vagrant/code";
	index index.html index.htm index.php;
	charset utf-8;
	location / {
		try_files \$uri \$uri/ /index.php?\$query_string;
	}
	location = /favicon.ico { access_log off; log_not_found off; }
	location = /robots.txt { access_log off; log_not_found off; }
	access_log off;
	error_log /var/log/nginx/vagrantvm-error.log error;
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		}
	}
EOF
