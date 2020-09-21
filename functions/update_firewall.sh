echo ""
#add more rules to firewall
printf -- "\e[0m\e[37m-> updating firewall\e[0m";
printf -- "\n";
update_firewall () {
	sudo ufw allow 'Nginx HTTP' 1>>$logfile 2>>$errlog
	sudo ufw allow 'Nginx HTTPS' 1>>$logfile 2>>$errlog
	sudo ufw allow 'Nginx Full' 1>>$logfile 2>>$errlog
	printf -- "\e[90mfirewall updated\e[22m"
}
update_firewall
echo ""