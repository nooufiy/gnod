#!/bin/bash

#rsync -avzh --progress root@104.248.193.237:/home/* /home

cd /home/gnod

yum -y install firewalld
sed -i 's/AllowZoneDrifting=yes/AllowZoneDrifting=no/g' /etc/firewalld/firewalld.conf
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-port=3003/tcp
firewall-cmd --permanent --zone=public --add-port=3004/tcp
firewall-cmd --permanent --zone=public --add-port=3005/tcp
firewall-cmd --permanent --zone=public --add-port=3006/tcp
firewall-cmd --reload
firewall-cmd --zone=public --list-ports
iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT

npm install pm2 -g
pm2 start index.js --name "gnod-01" -- 3003 gnod-1
pm2 start index.js --name "gnod-02" -- 3004 gnod-2
pm2 start index.js --name "gnod-03" -- 3005 gnod-3
pm2 start index.js --name "gnod-04" -- 3006 gnod-4
pm2 startup systemd
pm2 save

