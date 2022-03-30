#!/bin/bash
# simple shell script to install GOautodial and dependencies
# put in ks.cfg %post section

# default variables
GOSRCDIR=/usr/src/goautodial
APPKONFPL="listener.pl"
ASTCFGDIR=/etc/asterisk
ASTRECDIR=/var/spool/asterisk
ASTERISKDB="asterisk"
ASTPERLFILE="asterisk-perl-0.08.tar.gz"
ASTPERLDIR=/usr/src/asterisk-perl-0.08
GOAUTODIALDB="goautodial"
GOCRMCFGFILE="goCRMAPISettings.php"
KAMAILIODIR=/etc/kamailio
KAMAILIOCONF="kamailio.cfg"
KAMAILIOLOGDIR=/var/log/kamailio
MARIADBLOGDIR=/var/log/mariadb
MYFQDN="vaglxc01.goautodial.com"
RTPENGINEDIR=/etc/rtpengine
RTPENGINECONF="rtpengine.conf"
WEBROOT=/var/www/html

# get IP address
IPADDRESS=$(ip -o addr show up primary scope global |
      while read -r num dev fam addr rest; do echo ${addr%/*}; done)
IPADDRESS=`echo $IPADDRESS | awk '{print $1}'`

# update IP address entries on Kamailio and RTPengine
sed -i "s/123.234.345.456/${IPADDRESS}/g" ${RTPENGINEDIR}/${RTPENGINECONF}
sed -i "s/10.10.100.19/${IPADDRESS}/g" ${KAMAILIODIR}/${KAMAILIOCONF}
#sed -i "s/192.168.100.19/${IPALIASADDR}/g" ${KAMAILIODIR}/${KAMAILIOCONF}
sed -i "s/vaglxc01.goautodial.com/${IPADDRESS}/g" ${WEBROOT}/php/${GOCRMCFGFILE}

# restart RTPengine and iptables
systemctl restart ngcp-rtpengine
systemctl restart iptables

sed -i "s/localhost4.localdomain4/localhost4.localdomain4 ${MYFQDN}/g" /etc/hosts

# create log dirs for Kamailio and MariaDB
mkdir -p ${MARIADBLOGDIR} ${KAMAILIOLOGDIR}
touch ${MARIADBLOGDIR}/mariadb.log ${KAMAILIOLOGDIR}/kamailio.log
chown mysql.mysql -R ${MARIADBLOGDIR}
chown kamailio.kamailio -R ${KAMAILIOLOGDIR}

# make sure MariaDB is running

for i in {1..3}; do
systemctl status mariadb
 if [ $? > 0 ]; then
 systemctl start mariadb
 sleep 5
 systemctl status mariadb >> /root/log.log
 fi
done

# install SQL data
for sql in ${GOSRCDIR}/sql/*.sql; do
        mysql -u root < $sql;
done

# update settings
mysql -u root ${GOAUTODIALDB} -e "UPDATE settings SET value='${IPADDRESS}' WHERE value='vaglxc01.goautodial.com';"
mysql -u root ${ASTERISKDB} -e "UPDATE servers SET alt_server_ip='${IPADDRESS}';"
mysql -u root ${ASTERISKDB} -e "UPDATE servers SET recording_web_link='ALT_IP';"

# install asterisk-perl
cd /usr/src
tar zxvf ${GOSRCDIR}/${ASTPERLFILE}
cd ${ASTPERLDIR}
perl Makefile.PL
make all
make install

# fix Asterisk recordings directory permissions
chmod 755 ${ASTRECDIR}
chmod 755 ${ASTRECDIR}/monitorDONE

# install listener.pl to /usr/local/bin
cp -f ${GOSRCDIR}/${APPKONFPL} /usr/local/bin/

#fix upgrade to latest version from GitHub
cd /var/www/html
git config --global user.email "root@localhost" 
git stash
git pull
cd /var/www/html/goAPIv2
git stash
git pull
wget -O "/var/www/html/php/Config.php" "https://raw.githubusercontent.com/cyfran/goautodial/main/Config.php"
wget -O "/var/www/html/php/goCRMAPISettings.php" "https://raw.githubusercontent.com/cyfran/goautodial/main/goCRMAPISettings.php"
sed -i "s/123.234.345.456/${IPADDRESS}/g" /var/www/html/php/goCRMAPISettings.php
wget -O "/mysqlfix.sql" "https://raw.githubusercontent.com/cyfran/goautodial/main/mysqlfix.sql"
mysql < /mysqlfix.sql
rm -f /mysqlfix.sql

# remove firstboot file
rm -f /.firstboot
