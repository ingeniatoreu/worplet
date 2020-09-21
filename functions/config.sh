#version
source functions/version.sh

#get user input for domain
echo -e ""
echo -e "\e[0m\e[37mLeave the domain blank and hit enter to use the server's external IP instead of domain for this installation!\e[0m"
echo -e ""
read -p "Enter domain name (FQDN without http://www.): " domainname
server=$domainname
printf -- "\n";

#check if string is empty
check_domain () {
    if [[ -z "$server" ]]; then
        echo -e "\e[91m"
        printf -- "\n";
        printf -- "Domain field submitted empty. Using server's external IP address for installation.";
        serverip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        printf -- "\n";
        echo -e "\e[0m"
        ${0}
    else
        #use input in a loop
        for h in $server
        do
            host $h 2>&1
            if [ $? -eq 0 ]
            then
                printf -- "\n";
            else
                echo -e "\e[91m"
                printf -- "\n";
                printf -- "$h is not a FQDN";
                printf -- "\n";
                printf -- "Please try again.";
                printf -- "\n";
                echo -e "\e[0m"
                ${0}
            fi
        done
    fi
}
check_domain

#read server info
cpu=$(grep -c ^processor /proc/cpuinfo) 1>>$logfile 2>>$errlog
memorytotal=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024}') 1>>$logfile 2>>$errlog
storagetotal=$(df -h --output=size --total | awk 'END {print $1}') 1>>$logfile 2>>$errlog

#write server info
server_info () {
    printf -- "SERVER INFO";
    printf -- "\n";
    printf -- "\e[90mvCPU: $cpu\e[22m";
    printf -- "\n";
    printf -- "\e[90mRAM: $memorytotal Mb\e[22m";
    printf -- "\n";
    printf -- "\e[90mSTORAGE: $storagetotal\e[22m";
    printf -- "\n";
    printf -- "\n";
}
server_info

#add swap file equal to total system memory size
printf -- "\e[0m\e[37m-> adding swap\e[0m";
printf -- "\n";
add_swap_file () {
    ram=$(free -h | awk '/^Mem:/ { print $2 }') 1>>$logfile 2>>$errlog
    sudo fallocate -l ${ram} /swapfile 1>>$logfile 2>>$errlog
    ls -lh /swapfile 1>>$logfile 2>>$errlog
    sudo chmod 600 /swapfile 1>>$logfile 2>>$errlog && sudo mkswap /swapfile 1>>$logfile 2>>$errlog && sudo swapon /swapfile 1>>$logfile 2>>$errlog && sudo swapon 1>>$logfile 2>>$errlog
    sudo echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab 1>>$logfile 2>>$errlog
    swapsize=$(free -h | awk '/^Swap:/ { print $2 }') 1>>$logfile 2>>$errlog
    printf -- "\e[90mswap size set to $swapsize\e[22m";
}
add_swap_file
echo ""
echo ""

#increase maximum number of open files limit
printf -- "\e[0m\e[37m-> increasing max open files\e[0m";
printf -- "\n";
increase_open_files () {
    getmaxfiles="sudo cat /proc/sys/fs/file-max" 1>>$logfile 2>>$errlog
    eval "$getmaxfiles" 1>>$logfile 2>>$errlog
    maxfiles=$(eval "$getmaxfiles") 1>>$logfile 2>>$errlog
    echo "fs.file-max: $maxfiles" | sudo tee -a /etc/sysctl.conf 1>>$logfile 2>>$errlog
    printf -- "\e[90mmax. open files limit set to $maxfiles\e[22m";
}
increase_open_files
echo ""
echo ""

#improve swappiness & cache pressure
printf -- "\e[0m\e[37m-> improving swappiness & cache pressure\e[0m";
printf -- "\n";
improve_swappiness_cache_pressure () {
    sudo echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf 1>>$logfile 2>>$errlog
    sudo echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf 1>>$logfile 2>>$errlog
    printf -- "\e[90mswappiness set to 10\e[22m";
    printf -- "\n";
    printf -- "\e[90mcache pressure set to 50\e[22m";
}
improve_swappiness_cache_pressure
echo ""
echo ""

#generate a new sha256 password for mysql database
generate_password () {
    dbpassword=$(date +%s | sha256sum | base64 | head -c 32 ;)
    dbpass=$dbpassword
}
generate_password