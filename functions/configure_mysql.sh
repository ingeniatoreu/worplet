echo ""
#configure mysql
printf -- "\e[0m\e[37m-> configuring mysql\e[0m";
printf -- "\n";
configure_mysql () {
	sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('${dbpass}') WHERE User = 'root'" 1>>$logfile 2>>$errlog &&
	sudo mysql -e "FLUSH PRIVILEGES" 1>>$logfile 2>>$errlog
	printf -- "\e[90mupdated mysql password for user: root\e[22m"
	printf -- "\n";
	printf -- "\e[90mprivileges flushed\e[22m"
}
configure_mysql
echo ""