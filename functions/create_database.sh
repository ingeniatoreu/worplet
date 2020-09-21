echo ""
#create mysql database
printf -- "\e[0m\e[37m-> creating database\e[0m";
printf -- "\n";
create_database () {
	sudo mysql -uroot -p$dbpass -e "CREATE DATABASE wordpress;" 1>>$logfile 2>>$errlog &&
	sudo mysql -uroot -p$dbpass -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '${dbpass}';" 1>>$logfile 2>>$errlog &&
	sudo mysql -uroot -p$dbpass -e "GRANT ALL ON wordpress.* TO 'wpuser'@'localhost' IDENTIFIED BY '${dbpass}' WITH GRANT OPTION;" 1>>$logfile 2>>$errlog &&
	sudo mysql -uroot -p$dbpass -e "FLUSH PRIVILEGES;" 1>>$logfile 2>>$errlog
	printf -- "\e[90mcreated a database\e[22m"
	printf -- "\n";
	printf -- "\e[90mcreated a user\e[22m"
	printf -- "\n";
	printf -- "\e[90mgranted privilegies to user\e[22m"
	printf -- "\n";
	printf -- "\e[90mprivilegies flushed\e[22m"
}
create_database
echo ""