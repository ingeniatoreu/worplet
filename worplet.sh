#!/bin/bash
#

#output handling
source functions/output_handling.sh

#install dependencies
source functions/install_dependencies.sh
echo ""
echo ""
echo -ne '\e[32m####______________________(25%)\r\e[0m'
echo ""
echo ""
sleep 1

#configure
source functions/config.sh
echo ""
echo -ne '\e[32m###______________________(15%)\r\e[0m'
echo ""
echo ""
echo ""
sleep 1

#enable services
source functions/enable_services.sh
echo ""
echo ""
echo -ne '\e[32m#####_____________________(35%)\r\e[0m'
echo ""
echo ""
sleep 1

#update
source functions/update.sh
echo ""
echo ""
echo -ne '\e[32m#######___________________(45%)\r\e[0m'
echo ""
echo ""
sleep 1

#set firewall
source functions/set_firewall.sh
echo ""
echo ""
echo -ne '\e[32m#########_________________(50%)\r\e[0m'
echo ""
echo ""
sleep 1

#configure nginx
source functions/configure_nginx.sh
echo ""
echo ""
echo -ne '\e[32m###########_______________(55%)\r\e[0m'
echo ""
echo ""
sleep 1

#configure php
source functions/configure_php.sh
echo ""
echo ""
echo -ne '\e[32m#############_____________(65%)\r\e[0m'
echo ""
echo ""
sleep 1

#install mysql
source functions/configure_mysql.sh
echo ""
echo ""
echo -ne '\e[32m###############___________(75%)\r\e[0m'
echo ""
echo ""
sleep 1

#update firewall
source functions/update_firewall.sh
echo ""
echo ""
echo -ne '\e[32m#################_________(85%)\r\e[0m'
echo ""
echo ""
sleep 1

#set database
source functions/create_database.sh
echo ""
echo ""
echo -ne '\e[32m###################_______(95%)\r\e[0m'
echo ""
echo ""
sleep 1

#install wordpress
source functions/install_wordpress.sh
echo -ne '\e[32m######################### (100%)\r\e[0m'
echo ""
echo ""
sleep 1