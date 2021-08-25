#!/bin/bash

#set webserver [apache || nginx]

svt=$1                  # web server type (1 = apache | 2 = nginx)
acsf=$2                 # add firewall y/n

yum install -y gcc-c++ make 
yum install -y epel-release
yum install -y htop
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - 
yum install nodejs -y
yum install perl git nano wget htop -y
# curl -o- -L https://yarnpkg.com/install.sh | bash
npm install -g auto-install pm2 http-server
npm install -g cloudflare-cli
npm install -g nodemon
node -v
npm -v

if [ "$acsf" === "y" ]; then
  # Add Firewall
  cd /usr/src
  curl -sO https://download.configserver.com/csf.tgz 
  tar -xzf csf.tgz
  cd csf/
  sh install.sh
  sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf 
  csf -r
  sed -i 's/TCP_IN = "20,21/TCP_IN = "20,21,3003/g' /etc/csf/csf.conf
  sed -i 's/TCP_OUT = "20,21/TCP_IN = "20,21,3003/g' /etc/csf/csf.conf
  csf -r

  systemctl start csf
  systemctl start lfd
  systemctl enable csf
  systemctl enable lfd
else
  yum -y install firewalld
  sed -i 's/AllowZoneDrifting=yes/AllowZoneDrifting=no/g' /etc/firewalld/firewalld.conf
  firewall-cmd --permanent --zone=public --add-service=http
  firewall-cmd --permanent --zone=public --add-service=https
  firewall-cmd --permanent --zone=public --add-port=3003/tcp
  firewall-cmd --reload
  firewall-cmd --zone=public --list-ports
  iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
fi

cd /home
mkdir gnod
cd gnod
curl -sO https://raw.githubusercontent.com/nooufiy/gnod/main/sv.js            #silent&createfile
ip=$(hostname -I | sed 's/ //g')
sed -i "s/ipserver/$ip/g" sv.js

nodemon sv

npm install pm2 -g
#pm2 start sv.js
#pm2 startup systemd
#pm2 save

if [ "$svt" === 2 ]; then
  # Add Nginx
  yum install epel-release -y
  yum install nginx -y
  cd /home
  chown -R nginx:nginx gnod

  sed -i 's/server_name  localhost;/server_name  gnode;/g' /etc/nginx/nginx.conf
  # config blm lengkap
  
  systemctl restart nginx
  systemctl enable nginx
  
  setsebool -P httpd_can_network_relay on
  setsebool -P httpd_can_network_connect on
  
elif [ "$svt" === 1 ]; then
  # Add Apache
  yum -y install httpd
  
  # LoadModule proxy_module modules/mod_proxy.so >> /etc/httpd/conf/httpd.conf
  # LoadModule proxy_http_module modules/mod_proxy_http.so >> /etc/httpd/conf/httpd.conf
  curl https://raw.githubusercontent.com/nooufiy/gnod/main/vhos.txt >> /etc/httpd/conf/httpd.conf
  sed -i "s/ipserver/$ip/g" /etc/httpd/conf/httpd.conf
  
  chown -R apache:apache gnod
  
  systemctl start httpd.service
  systemctl enable httpd.service
  
  setsebool -P httpd_can_network_relay on
  setsebool -P httpd_can_network_connect on
else
  echo "[webserver not installed]"
fi

#firewall-cmd --permanent --add-service=http
#firewall-cmd --reload

#systemctl start pm2-root
#systemctl status pm2-root


echo "[Done]"
