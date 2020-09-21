echo ""
#configure nginx
printf -- "\e[0m\e[37m-> configuring nginx\e[0m";
printf -- "\n";
configure_nginx () {
	sudo sed -i "s|worker_connections 768;|worker_connections ${maxfiles};|g" "/etc/nginx/nginx.conf" 1>>$logfile 2>>$errlog
	printf -- "\e[90mnginx worker connections set to: ${maxfiles}\e[22m"
}
configure_nginx
echo ""