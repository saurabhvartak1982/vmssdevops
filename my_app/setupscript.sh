#!/bin/bash

sudo apt update
sudo apt install python3 -y
sudo apt install python3-pip -y 
sudo apt install nginx -y
pip3 install uwsgi flask 

drop_location=$(pwd)
echo "drop location is ***"
echo $drop_location

cd drop
ls

mkdir /var/www/html/my_app

cp app.py /var/www/html/my_app/ 
cp wsgi.py /var/www/html/my_app/
cp app.ini /var/www/html/my_app/

chown -R www-data.www-data /var/www/html/my_app/

cp my_app.service /etc/systemd/system/

sudo systemctl start my_app
sudo systemctl status my_app.service
ls /var/www/html/my_app/my_app.sock
sudo systemctl enable my_app

cp my_app /etc/nginx/sites-enabled/

sudo systemctl restart nginx
