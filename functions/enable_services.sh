echo ""
#enable services
printf -- "\e[0m\e[37m-> enabling services\e[0m";
printf -- "\n";
enable_services () {
	sudo systemctl enable nginx.service 1>>$logfile 2>>$errlog &&
	sudo systemctl enable mariadb.service 1>>$logfile 2>>$errlog &&
	sudo systemctl enable php7.2-fpm.service 1>>$logfile 2>>$errlog &&
	printf -- "\e[90mrestarted services: nginx, mariadb, php\e[22m"
}
enable_services
echo ""