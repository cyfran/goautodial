#!/bin/bash

yum -y install asterisk-mysql-13.17.2-vici.el7.centos.x86_64 asterisk-perl-0.08-2.go.x86_64 asterisk-voicemail-plain-13.17.2-vici.el7.centos.x86_64 \
asterisk-devel-13.17.2-vici.el7.centos.x86_64 asterisk-voicemail-13.17.2-vici.el7.centos.x86_64 asterisk-alsa-13.17.2-vici.el7.centos.x86_64 \
asterisk-sip-13.17.2-vici.el7.centos.x86_64 asterisk-13.17.2-vici.el7.centos.x86_64 asterisk-dahdi-13.17.2-vici.el7.centos.x86_64 \ 
asterisk-iax2-13.17.2-vici.el7.centos.x86_64 asterisk-mp3-13.17.2-vici.el7.centos.x86_64 kamailio-tls kamailio kamailio-mysql kamailio-ims \
kamailio-utils kamailio-websocket kamailio-json

yum -y install goautodial-ce
cd /usr/src/goautodial
./install.sh
sed -i "s/:OUTPUT DROP/:OUTPUT ACCEPT/g" /etc/sysconfig/iptables
systemctl restart iptables

myip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
sed -i "s/123.234.345.456/$myip/g" /etc/rtpengine/rtpengine.conf
sed -i "s/10.10.100.19/$myip/g" /etc/kamailio/kamailio.cfg

echo > run.sh
