echo ""
#update and upgrade
printf -- "\e[0m\e[37m-> updating\e[0m";
printf -- "\n";
update_and_upgrade () {
	sudo apt-get update 1>>$logfile 2>>$errlog && sudo apt-get upgrade -y 1>>$logfile 2>>$errlog
	printf -- "\e[90mupdate completed\e[22m"
}
update_and_upgrade
echo ""