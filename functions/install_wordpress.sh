echo ""
#get wordpress
printf -- "\e[0m\e[37m-> downlading wordpress\e[0m";
printf -- "\n";
get_wordpress () {
  cd /tmp && wget https://wordpress.org/latest.tar.gz 1>>$logfile 2>>$errlog
  printf -- "\e[90mlatest wordpress version downloaded\e[22m"
}
get_wordpress
echo ""
echo ""

#decompress files
printf -- "\e[0m\e[37m-> decompressing files\e[0m";
printf -- "\n";
decompress_files () {
  tar -zxvf latest.tar.gz 1>>$logfile 2>>$errlog
  printf -- "\e[90mfiles decompressed\e[22m"
}
decompress_files
echo ""
echo ""

#install wordpress
printf -- "\e[0m\e[37m-> installing wordpress\e[0m";
printf -- "\n";
move_wordpress_directory () {
  sudo mv wordpress /var/www/html/wordpress 1>>$logfile 2>>$errlog
  printf -- "\e[90mwordpress installed\e[22m"
}
move_wordpress_directory
echo ""
echo ""

#set privilegies
printf -- "\e[0m\e[37m-> setting privilegies\e[0m";
printf -- "\n";
set_privilegies () {
  sudo chown -R www-data:www-data /var/www/html/wordpress/ 1>>$logfile 2>>$errlog &&
  sudo chmod -R 755 /var/www/html/wordpress/ 1>>$logfile 2>>$errlog
  printf -- "\e[90mprivilegies set\e[22m"
}
set_privilegies
echo ""
echo ""

#configuring wordpress
printf -- "\e[0m\e[37m-> configuring wordpress\e[0m";
printf -- "\n";
configure_wordpress () {
  sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php 1>>$logfile 2>>$errlog &&
  sudo sed -i "s/^define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wordpress' );/" /var/www/html/wordpress/wp-config.php 1>>$logfile 2>>$errlog &&
  sudo sed -i "s/^define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wpuser' );/" /var/www/html/wordpress/wp-config.php 1>>$logfile 2>>$errlog &&
  sudo sed -i "s/^define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${dbpass}' );/" /var/www/html/wordpress/wp-config.php 1>>$logfile 2>>$errlog &&
  SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
  STRING='put your unique phrase here' 1>>$logfile 2>>$errlog
  printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wordpress/wp-config.php 1>>$logfile 2>>$errlog
  printf -- "\e[90mwordpress configured\e[22m"
}
configure_wordpress
echo ""
echo ""

#install nginx site config
printf -- "\e[0m\e[37m-> configuring server\e[0m";
printf -- "\n";
configure_nginx_site () {
  cd /etc/nginx/sites-available/ 1>>$logfile 2>>$errlog &&
  sudo curl -L -O https://raw.githubusercontent.com/ingeniatoreu/worplet/master/wordpress 1>>$logfile 2>>$errlog &&
  sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/ 1>>$logfile 2>>$errlog
  printf -- "\e[90mserver configured\e[22m"
}
configure_nginx_site
echo ""
echo ""

#enable gzip
printf -- "\e[0m\e[37m-> enabling gzip\e[0m";
printf -- "\n";
enable_gzip () {
  sudo sed -i "s|#gzip on;|gzip on;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_vary on;|gzip_vary on;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_disable "msie6";|gzip_disable "msie6";|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_proxied any;|gzip_proxied any;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_comp_level 6;|gzip_comp_level 6;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_buffers 16 8k;|gzip_buffers 16 8k;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_http_version 1.1;|gzip_http_version 1.1;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog &&
  sudo sed -i "s|# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;|gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog
  printf -- "\e[90mgzip enabled on the server\e[22m"
}
enable_gzip
echo ""
echo ""

#configure domain
printf -- "\e[0m\e[37m-> configuring domain\e[0m";
printf -- "\n";
configure_domain () {
  sudo sed -i "s|YOURDOMAINNAME|$server$serverip|g" "/etc/nginx/sites-available/wordpress" 1>>$logfile 2>>$errlog &&
  printf -- "\e[90mdomain configured\e[22m"
}
configure_domain
echo ""
echo ""

#install SSL certificate
printf -- "\e[0m\e[37m-> installing ssl\e[0m";
printf -- "\n";
isntall_ssl () {
  sudo certbot --nginx --agree-tos --register-unsafely-without-email -d ${server}${serverip} --redirect --post-hook "service nginx start" 1>>$logfile 2>>$errlog
  printf -- "\e[90mssl installed\e[22m"
}
isntall_ssl
echo ""
echo ""

#post install clean up
printf -- "\e[0m\e[37m-> doing clean up\e[0m";
printf -- "\n";
clean_up () {
  sudo apt-get autoremove -y 1>>$logfile 2>>$errlog && sudo apt-get clean -y 1>>$logfile 2>>$errlog && sudo apt-get purge -y 1>>$logfile 2>>$errlog
  printf -- "\e[90mclean up done\e[22m"
}
clean_up 
echo ""
echo ""

#restart all services
printf -- "\e[0m\e[37m-> restarting services\e[0m";
printf -- "\n";
restart_services () {
  sudo systemctl restart nginx.service php7.2-fpm.service mysql.service 1>>$logfile 2>>$errlog
  printf -- "\e[90mservices restarted\e[22m\e[0m"
}
restart_services
echo ""
echo ""

#help text
printf -- "Your new WordPress site is available @ \e[33m$h\e[0m";
printf -- "\n";
printf -- "Full installation log is available @ \e[33m/var/log/worplet.log\e[0m";
printf -- "\n";
printf -- "Error log is available @ \e[33m/var/log/worplet_error.log\e[0m";
printf -- "\n";
printf -- "Thank you for using Worplet install script!";
printf -- "\n";
echo ""
