
if [[ $1 != 'skip' ]]; then
	# ONBOOT=yes
	vi /etc/sysconfig/network-scripts/ifcfg-enp0s3

	# ONBOOT=yes
	# BOOTPROTO=none
	# IPADDR=192.168.56.141
	# PREFIX=24
	vi /etc/sysconfig/network-scripts/ifcfg-enp0s8

	service network restart
	yum update -y
	yum install -y vim wget
	yum install -y ntp httpd mod_ssl php php-mysql php-mbstring
	rpm -Uvh mysql.rpm
	yum install -y mysql-server
	systemctl start mysqld httpd
	systemctl enable httpd
	grep password /var/log/mysqld.log
	mysql_secure_installation
fi

echo "Insert new phpMyAdmin password..."
read pass
echo "
	CREATE USER admin@localhost IDENTIFIED WITH mysql_native_password BY '$pass';
	\q
" | mysql -u root -p

yum install -y epel-release
yum install -y phpmyadmin

# All "127.0.0.1" to "192.168.56.141" (4)
# Add "Require all granted" after first IP
vim /etc/httpd/conf.d/phpMyAdmin.conf

systemctl restart httpd

for zone in home public
do
	firewall-cmd --permanent --zone=$zone \
	--add-service=http \
	--add-service=https \
	--add-service=mysql
done

firewall-cmd --complete-reload
printf "\n<?php\n\nphpinfo();" > /var/www/html/index.php
	
