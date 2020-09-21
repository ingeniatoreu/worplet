#!/bin/bash

# exit on error
set -e

#create log for output
LOG="/var/log/worplet.log"
ERR_LOG="/var/log/worplet_err.log"

#check to see if the script has already run on this server
serveripcheck=$(dig +short myip.opendns.com @resolver1.opendns.com)
filecheck=/etc/nginx/sites-available/wordpress
if grep -q $serveripcheck "$filecheck"; then
  printf -- "\n"
  printf -- "\e[91mScript is already installed - aborting...\e[0m"
  printf -- "\n"
  exit 1
else
  printf -- "\n"
  printf -- "\e[92mScript is not installed - running...\e[0m"
  printf -- "\n"
fi
echo

#version
echo
printf -- "\n"
printf -- "\e[93mWORPLET [v1.1] \e[0m"
printf -- "\n"
printf -- "\e[2mautomatic wordpress installer and optimizer!\e[0m"
printf -- "\n"
printf -- "\e[2mcopyright (c) 2019, ingdevs\e[0m"
printf -- "\n"

#public IP
public_ip=$serveripcheck

#wordpress version
wp_version_latest=latest.tar.gz

#system info
echo
cpucores=$(cat /proc/cpuinfo | grep processor | wc -l)
ramsize=$(free -h | awk '/^Mem:/ { print $2 }')
storagetotal=$(df -h --total | grep total)
echo -e ""
echo -e "\e[95mSYSTEM INFO\e[0m"
echo -e ""
echo -e "\e[2mvCPU: $cpucores"
echo -e "MEMORY: $ramsize"
echo -e "PUBLIC IP: $public_ip"
echo -e "STORAGE:         max   used  free used"
echo -e "$storagetotal\e[0m"
echo

#update and upgrade
echo
printf -- "updating system..."
printf -- "\n"
update_and_upgrade () {
  sudo apt-get update && sudo apt-get upgrade -y
}
update_and_upgrade 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92msystem updated\e[0m"
printf -- "\n"

#install dependencies
echo
printf -- "installing dependencies..."
printf -- "\n"
install_dependencies () {
  sudo apt-get -y install nginx
  sudo apt-get -y install mariadb-server
  sudo apt-get -y install mariadb-client
  sudo apt-get -y install php7.2-fpm
  sudo apt-get -y install php7.2-common
  sudo apt-get -y install php7.2-mbstring
  sudo apt-get -y install php7.2-xmlrpc
  sudo apt-get -y install php7.2-gd
  sudo apt-get -y install php7.2-xml
  sudo apt-get -y install php7.2-mysql
  sudo apt-get -y install php7.2-cli
  sudo apt-get -y install php7.2-zip
  sudo apt-get -y install php7.2-curl
  sudo apt-get -y install php7.2-soap
  sudo apt-get -y install php7.2-intl
  sudo apt-get -y install php7.2-ldap

}
install_dependencies 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mdependencies installed\e[0m"
printf -- "\n"

#enable services
echo
printf -- "enabling services..."
printf -- "\n"
enable_services () {
  sudo systemctl enable nginx.service
  sudo systemctl enable mariadb.service
  sudo systemctl enable php7.2-fpm.service
}
enable_services 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mservices enabled\e[0m"
printf -- "\n"

#add swap file
echo
printf -- "adding swap file..."
printf -- "\n"
add_swap_file () {
    sudo fallocate -l 2G /swapfile
    ls -lh /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon
    sudo echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    swapsize=$(free -h | awk '/^Swap:/ { print $2 }')
}
add_swap_file 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mswap file added\e[0m"
printf -- "\n"

#increase maximum number of open files limit
echo
printf -- "increasing maximum number of open files limit..."
printf -- "\n"
increase_open_files () {
    getmaxfiles="sudo cat /proc/sys/fs/file-max"
    eval "$getmaxfiles"
    maxfiles=$(eval "$getmaxfiles")
    echo "fs.file-max: $maxfiles" | sudo tee -a /etc/sysctl.conf
}
increase_open_files 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mmaximum number of open files limit increased\e[0m"
printf -- "\n"

#improve swappiness & cache pressure
echo
printf -- "improving swappiness & cache pressure..."
printf -- "\n"
improve_swappiness_cache_pressure () {
    sudo echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    sudo echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
}
improve_swappiness_cache_pressure 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mswappiness & cache pressure improved\e[0m"
printf -- "\n"

#generate a new sha256 password for mysql database
echo
printf -- "generating a new sha256 password..."
printf -- "\n"
generate_password () {
    dbpassword=$(date +%s | sha256sum | base64 | head -c 32 ;)
    dbpass=$dbpassword
}
generate_password 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mnew sha256 password generated\e[0m"
printf -- "\n"

#set standard firewall options
echo
printf -- "setting standard firewall options..."
printf -- "\n"
set_firewall () {
	sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  yes | sudo ufw enable
  sudo ufw allow 80
  sudo ufw allow 443
}
set_firewall 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mstandard firewall options set\e[0m"
printf -- "\n"

#configure nginx
echo
printf -- "configuring nginx..."
printf -- "\n"
configure_nginx () {
	sudo sed -i "s|worker_connections 768;|worker_connections ${maxfiles};|g" "/etc/nginx/nginx.conf"
}
configure_nginx 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mnginx configured\e[0m"
printf -- "\n"

#configure php
echo
printf -- "configuring php..."
printf -- "\n"
configure_php () {
	sudo sed -i "s/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini &&
	sudo sed -i "s/^max_execution_time = 30/max_execution_time = 360/" /etc/php/7.2/fpm/php.ini &&
	sudo sed -i "s/^memory_limit = 128M/memory_limit = 256M/" /etc/php/7.2/fpm/php.ini &&
	sudo sed -i "s/^upload_max_filesize = 2M/upload_max_filesize = 64M/" /etc/php/7.2/fpm/php.ini &&
	sudo sed -i "s/^post_max_size = 8M/post_max_size = 64M/" /etc/php/7.2/fpm/php.ini
}
configure_php 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mphp configured\e[0m"
printf -- "\n"

#configure mysql
echo
printf -- "configuring mysql..."
printf -- "\n"
configure_mysql () {
	sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('${dbpass}') WHERE User = 'root'" &&
	sudo mysql -e "FLUSH PRIVILEGES"
}
configure_mysql 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mmysql configured\e[0m"
printf -- "\n"

#add more rules to firewall
echo
printf -- "adding more rules to firewall..."
printf -- "\n"
update_firewall () {
	sudo ufw allow 'Nginx HTTP'
	sudo ufw allow 'Nginx HTTPS'
	sudo ufw allow 'Nginx Full'
}
update_firewall 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mmore rules added to firewall\e[0m"
printf -- "\n"

#create mysql database
echo
printf -- "creating mysql database..."
printf -- "\n"
create_database () {
	sudo mysql -uroot -p$dbpass -e "CREATE DATABASE wordpress;" &&
	sudo mysql -uroot -p$dbpass -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '${dbpass}';" &&
	sudo mysql -uroot -p$dbpass -e "GRANT ALL ON wordpress.* TO 'wpuser'@'localhost' IDENTIFIED BY '${dbpass}' WITH GRANT OPTION;" &&
	sudo mysql -uroot -p$dbpass -e "FLUSH PRIVILEGES;"
}
create_database 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mmysql database created\e[0m"
printf -- "\n"

#download wordpress
echo
printf -- "downloading wordpress..."
printf -- "\n"
get_wordpress () {
  cd /tmp && wget https://wordpress.org/latest.tar.gz
}
get_wordpress 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mwordpress downloaded\e[0m"
printf -- "\n"

#decompress files
echo
printf -- "decompressing files..."
printf -- "\n"
decompress_files () {
  tar -zxvf latest.tar.gz
}
decompress_files 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mfiles decompressed\e[0m"
printf -- "\n"

#install wordpress
echo
printf -- "installing wordpress..."
printf -- "\n"
move_wordpress_directory () {
  sudo mv wordpress /var/www/html/wordpress
}
move_wordpress_directory 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mwordpress installed\e[0m"
printf -- "\n"

#set privilegies
echo
printf -- "setting privilegies..."
printf -- "\n"
set_privilegies () {
  sudo chown -R www-data:www-data /var/www/html/wordpress/ &&
  sudo chmod -R 755 /var/www/html/wordpress/
}
set_privilegies 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mprivilegies set\e[0m"
printf -- "\n"

#configure wordpress
echo
printf -- "configuring wordpress..."
printf -- "\n"
configure_wordpress () {
  sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php &&
  sudo sed -i "s/^define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wordpress' );/" /var/www/html/wordpress/wp-config.php &&
  sudo sed -i "s/^define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wpuser' );/" /var/www/html/wordpress/wp-config.php &&
  sudo sed -i "s/^define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${dbpass}' );/" /var/www/html/wordpress/wp-config.php &&
  SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
  STRING='put your unique phrase here'
  printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wordpress/wp-config.php
}
configure_wordpress 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mwordpress configured\e[0m"
printf -- "\n"

#install nginx site config
echo
printf -- "installing nginx site config..."
printf -- "\n"
configure_nginx_site () {
  cd /etc/nginx/sites-available/ &&
  sudo curl -L -O https://raw.githubusercontent.com/ingdevs/worplet/master/wordpress &&
  sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
}
configure_nginx_site 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mnginx site config installed\e[0m"
printf -- "\n"

#enable gzip
echo
printf -- "enabling gzip..."
printf -- "\n"
enable_gzip () {
  sudo sed -i "s|#gzip on;|gzip on;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_vary on;|gzip_vary on;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_disable "msie6";|gzip_disable "msie6";|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_proxied any;|gzip_proxied any;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_comp_level 6;|gzip_comp_level 6;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_buffers 16 8k;|gzip_buffers 16 8k;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_http_version 1.1;|gzip_http_version 1.1;|g" "/etc/nginx/nginx.conf" &&
  sudo sed -i "s|# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;|gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;|g" "/etc/nginx/nginx.conf"
}
printf -- "\n"
printf -- "\e[92mgzip enabled\e[0m"
printf -- "\n"

#configure domain
echo
printf -- "configuring domain..."
printf -- "\n"
configure_ip () {
  sudo sed -i "s|YOURDOMAINNAME|$serveripcheck|g" "/etc/nginx/sites-available/wordpress"
}
configure_ip 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mdomain configured\e[0m"
printf -- "\n"

#restart all services
echo
printf -- "restarting all services..."
printf -- "\n"
restart_services () {
  sudo systemctl restart nginx.service php7.2-fpm.service mysql.service
}
restart_services 1>>$LOG 2>>$ERR_LOG
printf -- "\n"
printf -- "\e[92mservices restarted\e[0m"
printf -- "\n"

#Installation report
echo -e ""
echo -e "\e[95mINSTALLATION COMPLETE\e[0m"
echo -e ""
echo -e "\e[2mInstallation log can be found @ $LOG"
echo -e "\e[2mError log can be found @ $ERR_LOG"
echo -e "\e[2mWordPress installation can be found @ $public_ip"
echo -e "\e[2mThanks for using worplet install script."
echo
