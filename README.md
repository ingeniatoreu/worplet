# Worplet - a WordPress droplet
### Get WordPress spinning on a VPS at warp speed

&nbsp;

### Prerequisites

- VPS server with root access running Ubuntu 18.04 LTS
- Registered domain with DNS pointing to VPS server

&nbsp;

### Description

- Shell script that allows for an easy setup of a Linux server with php, mysql, nginx, wordpress, domain and ssl. All you need to quick start your development and skip the server setup manual labor.

&nbsp;

### Results

- VPS server will be running on latest WordPress installation
- VPS server will install PHP, MySQL and Nginx
- VPS server will create and populate new mysql database
- VPS server will create and configure all services without interaction
- VPS server will setup the domain and install an SSL certificate
- WordPress site files will be available in `/root/var/www/html/wordpress`

&nbsp;

## How to use

&nbsp;

### install git

`sudo apt install git -y`

### clone repository

`git clone https://github.com/ingdevs/worplet.git worplet`

### run

`cd worplet && sudo chmod +x *` 

`sudo ./run.sh`

&nbsp;

## Startup script for VM (IP only)

&nbsp;

### install git

`sudo apt install git -y`

### get startup file

`sudo wget https://raw.githubusercontent.com/ingdevs/worplet/master/startup.sh`

### run

`sudo chmod +x startup.sh` 

`sudo ./startup.sh`

&nbsp;
&nbsp;

Copyright (c) 2020, ingeniatoreu

&nbsp;

Published under GNU GENERAL PUBLIC LICENSE.
More info: https://www.gnu.org/licenses/
