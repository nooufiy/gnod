#!/bin/bash

yum install -y gcc-c++ make 
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - 
yum install nodejs -y
curl -o- -L https://yarnpkg.com/install.sh | bash
npm install -g auto-install
curl -sO https://raw.githubusercontent.com/nooufiy/gnod/main/sv.js            #silent&createfile
ip=$(hostname -I)
sed -i "s/127.0.0.1/$ip/g" sv.js
node -v
npm -v

echo "[Done]"
