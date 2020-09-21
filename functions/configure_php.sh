echo ""
#configure php
printf -- "\e[0m\e[37m-> configuring php\e[0m";
printf -- "\n";
configure_php () {
	sudo sed -i "s/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini 1>>$logfile 2>>$errlog &&
	sudo sed -i "s/^max_execution_time = 30/max_execution_time = 360/" /etc/php/7.2/fpm/php.ini 1>>$logfile 2>>$errlog &&
	sudo sed -i "s/^memory_limit = 128M/memory_limit = 256M/" /etc/php/7.2/fpm/php.ini 1>>$logfile 2>>$errlog &&
	sudo sed -i "s/^upload_max_filesize = 2M/upload_max_filesize = 64M/" /etc/php/7.2/fpm/php.ini 1>>$logfile 2>>$errlog &&
	sudo sed -i "s/^post_max_size = 8M/post_max_size = 64M/" /etc/php/7.2/fpm/php.ini 1>>$logfile 2>>$errlog
	printf -- "\e[90mcgi.fix_pathinfo set to 0\e[22m"
	printf -- "\n";
	printf -- "\e[90mmax_execution_time set to 360\e[22m"
	printf -- "\n";
	printf -- "\e[90mmemory_limit set to 256M\e[22m"
	printf -- "\n";
	printf -- "\e[90mupload_max_filesize set to 64M\e[22m"
	printf -- "\n";
	printf -- "\e[90mpost_max_size set to 64M\e[22m"
}
configure_php
echo ""