#!/bin/bash
mkdir -p /usr/share/info/ /etc/alternatives/
yum update -y
yum install -y epel-release
yum install -y httpd
sed -i "s/gpgcheck=1/gpgcheck=1\nexclude=dahdi-tools*/g" /etc/yum.repos.d/epel.repo
yum groupinstall -y "Development Tools" 
wget -O /etc/yum.repos.d/goautodial.repo http://downloads2.goautodial.org/centos/7/goautodial.repo
yum install -y MariaDB-server MariaDB-devel php70w-mysql php70w-mcrypt php70w-devel php70w-mbstring php70w-common php70w-xml php70w-pear php70w-cli php70w-imap php70w-fpm php70w-gd php70w-opcache php70w-pdo php70w-process php70w php70w-intl php70w-pear.noarch php70w-xmlrpc asterisk-mysql-13.17.2-vici.el7.centos.x86_64 asterisk-perl-0.08-2.go.x86_64 asterisk-voicemail-plain-13.17.2-vici.el7.centos.x86_64 asterisk-devel-13.17.2-vici.el7.centos.x86_64 asterisk-voicemail-13.17.2-vici.el7.centos.x86_64 asterisk-alsa-13.17.2-vici.el7.centos.x86_64 asterisk-sip-13.17.2-vici.el7.centos.x86_64 asterisk-13.17.2-vici.el7.centos.x86_64 asterisk-dahdi-13.17.2-vici.el7.centos.x86_64 asterisk-iax2-13.17.2-vici.el7.centos.x86_64 asterisk-mp3-13.17.2-vici.el7.centos.x86_64 kamailio-tls kamailio kamailio-mysql kamailio-ims kamailio-utils kamailio-websocket  kamailio-json perl-Math-Round perl-Net-Server perl-File-Touch perl-Sys-RunAlone perl-Switch perl-Time-Local ngcp-rtpengine ngcp-rtpengine-kernel ngcp-rtpengine-dkms dkms dahdi-linux dahdi-linux-devel kernel-devel perl-Crypt-Eksblowfish perl-DBI perl-DBD-mysql perl-Net-Telnet lame httpd mod_ssl screen crontabs mailx net-tools glibc.i686 perl-Crypt-Eksblowfish perl-Sys-RunAlone cpan perl-Digest-MD5

yum -y install goautodial-ce
cd /usr/src/goautodial
./install.sh

systemctl enable php-fpm 
systemctl enable httpd
systemctl enable mariadb
systemctl enable kamailio
systemctl enable ngcp-rtpengine
systemctl stop firewalld
systemctl disable firewalld
mkdir /var/run/kamailio
chown kamailio:kamailio /var/run/kamailio

SHELL=/bin/sh
cpan install Net::Server <<<yes
cpan install Test::More <<<yes
cpan install Asterisk::AGI <<<yes

wget -O "/usr/src/goautodial/rclocal.sh" "https://raw.githubusercontent.com/cyfran/goautodial/main/rclocal.sh"
sed -i "s/:OUTPUT DROP/:OUTPUT ACCEPT/g" /etc/sysconfig/iptables
touch /.firstboot

