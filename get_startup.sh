#!/bin/bash

#fetch and run the startup script
sudo apt install git -y
sudo mkdir worplet && cd worplet
sudo wget https://raw.githubusercontent.com/ingdevelopers/wordpress-droplet/master/startup.sh
sudo chmod +x startup.sh
sudo time ./startup.sh