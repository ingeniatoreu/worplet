#get ppa
printf -- "\e[0m\e[37m-> downloading repositories\e[0m";
printf -- "\n";
get_ppa () {
	yes | sudo add-apt-repository ppa:ondrej/php 1>>$logfile 2>>$errlog
	yes | sudo add-apt-repository ppa:certbot/certbot 1>>$logfile 2>>$errlog
	printf -- "\e[90madded repository: ppa:ondrej/php\e[22m"
	printf -- "\n";
	printf -- "\e[90madded repository: ppa:certbot/certbot\e[22m"
}
get_ppa
echo ""
echo ""

#update
printf -- "\e[0m\e[37m-> running updates\e[0m";
printf -- "\n";
get_update () {
	sudo apt-get update 1>>$logfile 2>>$errlog
	printf -- "\e[90mupdate completed\e[22m"
}
get_update
echo ""
echo ""

#install dependencies
printf -- "\e[0m\e[37m-> installing dependencies\e[0m";
printf -- "\n";
install_dependencies () {
	sudo apt-get -y install git nano ntp ntpdate nginx php7.2-fpm php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-gd php7.2-xml php7.2-mysql php7.2-cli php7.2-zip php7.2-curl php7.2-soap php7.2-intl php7.2-ldap mariadb-server mariadb-client certbot python-certbot-nginx 1>>$logfile 2>>$errlog
	printf -- "\e[90mfollowing dependencies have been isntalled: git nano ntp ntpdate nginx php7.2-fpm php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-gd php7.2-xml php7.2-mysql php7.2-cli php7.2-zip php7.2-curl php7.2-soap php7.2-intl php7.2-ldap mariadb-server mariadb-client certbot python-certbot-nginx\e[22m"
}
install_dependencies
echo ""