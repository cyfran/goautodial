#!/bin/bash

myip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
sed -i "s/123.234.345.456/$myip/g" /etc/rtpengine/rtpengine.conf
sed -i "s/10.10.100.19/$myip/g" /etc/kamailio/kamailio.cfg
echo > run.sh
