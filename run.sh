#!/bin/bash
mkdir -p /usr/share/info/ /etc/alternatives/
yum update -y
yum install -y nano wget bind-utils
yum groupinstall -y "Development Tools" 
wget -O /etc/yum.repos.d/goautodial.repo http://downloads2.goautodial.org/centos/7/goautodial.repo
yum -y install MariaDB-server MariaDB-devel php70w-mysql php70w-mcrypt php70w-devel php70w-mbstring php70w-common php70w-xml php70w-pear php70w-cli php70w-imap php70w-fpm php70w-gd php70w-opcache php70w-pdo php70w-process php70w php70w-intl php70w-pear.noarch php70w-xmlrpc asterisk-mysql-13.17.2-vici.el7.centos.x86_64 asterisk-perl-0.08-2.go.x86_64 asterisk-voicemail-plain-13.17.2-vici.el7.centos.x86_64 asterisk-devel-13.17.2-vici.el7.centos.x86_64 asterisk-voicemail-13.17.2-vici.el7.centos.x86_64 asterisk-alsa-13.17.2-vici.el7.centos.x86_64 asterisk-sip-13.17.2-vici.el7.centos.x86_64 asterisk-13.17.2-vici.el7.centos.x86_64 asterisk-dahdi-13.17.2-vici.el7.centos.x86_64 asterisk-iax2-13.17.2-vici.el7.centos.x86_64 asterisk-mp3-13.17.2-vici.el7.centos.x86_64 kamailio-tls kamailio kamailio-mysql kamailio-ims kamailio-utils kamailio-websocket  kamailio-json perl-Math-Round perl-Net-Server perl-File-Touch perl-Sys-RunAlone perl-Switch perl-Time-Local ngcp-rtpengine ngcp-rtpengine-kernel ngcp-rtpengine-dkms dkms dahdi-linux dahdi-linux-devel kernel-devel perl-Crypt-Eksblowfish perl-DBI perl-DBD-mysql perl-Net-Telnet lame httpd mod_ssl screen crontabs mailx net-tools glibc.i686
yum install -y epel-release
yum install perl-Crypt-Eksblowfish perl-Sys-RunAlone
echo "exclude=dahdi-tools*" >> /etc/yum.conf
yum update
systemctl enable php-fpm 
systemctl enable httpd
systemctl enable mariadb
systemctl enable kamailio
systemctl enable ngcp-rtpengine
systemctl stop firewalld
systemctl disable firewalld
mkdir /var/run/kamailio
chown kamailio /var/run/kamailio
yum -y install goautodial-ce
cd /usr/src/goautodial
./install.sh
yum install -y cpan perl-Digest-MD5
cpan install Net::Server <<<yes
cpan install Test::More <<<yes
cpan install Asterisk::AGI <<<yes

myip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
sed -i "s/123.234.345.456/$myip/g" /etc/rtpengine/rtpengine.conf
sed -i "s/10.10.100.19/$myip/g" /etc/kamailio/kamailio.cfg

cat <<EOF>> /var/spool/cron/root
### recording mixing/compressing/ftping scripts
0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_mix.pl
#0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_mix.pl --MIX
#0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_VDonly.pl
1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58 * * * * /usr/share/astguiclient/AST_CRON_audio_2_compress.pl --MP3
#2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59 * * * * /usr/share/astguiclient/AST_CRON_audio_3_ftp.pl --MP3

### keepalive script for astguiclient processes
* * * * * /usr/share/astguiclient/ADMIN_keepalive_ALL.pl

### kill Hangup script for Asterisk updaters
* * * * * /usr/share/astguiclient/AST_manager_kill_hung_congested.pl

### updater for voicemail
* * * * * /usr/share/astguiclient/AST_vm_update.pl

### updater for conference validator
* * * * * /usr/share/astguiclient/AST_conf_update.pl

### flush queue DB table every hour for entries older than 1 hour
11 * * * * /usr/share/astguiclient/AST_flush_DBqueue.pl -q

### fix the vicidial_agent_log once every hour and the full day run at night
33 * * * * /usr/share/astguiclient/AST_cleanup_agent_log.pl
50 0 * * * /usr/share/astguiclient/AST_cleanup_agent_log.pl --last-24hours

### updater for VICIDIAL hopper
* * * * * /usr/share/astguiclient/AST_VDhopper.pl -q

### adjust the GMT offset for the leads in the vicidial_list table
1 1 * * * /usr/share/astguiclient/ADMIN_adjust_GMTnow_on_leads.pl --debug

### reset several temporary-info tables in the database
2 1 * * * /usr/share/astguiclient/AST_reset_mysql_vars.pl

### optimize the database tables within the asterisk database
3 1 * * * /usr/share/astguiclient/AST_DB_optimize.pl

## adjust time on the server with ntp
30 * * * * /usr/sbin/ntpdate -u pool.ntp.org 2>/dev/null 1>&2

### VICIDIAL agent time log weekly and daily summary report generation
#2 0 * * 0 /usr/share/astguiclient/AST_agent_week.pl
#22 0 * * * /usr/share/astguiclient/AST_agent_day.pl

### VICIDIAL campaign export scripts (OPTIONAL)
#32 0 * * * /usr/share/astguiclient/AST_VDsales_export.pl
#42 0 * * * /usr/share/astguiclient/AST_sourceID_summary_export.pl

### remove old ORIG recordings more than 2 days old
24 0 * * * /usr/bin/find /var/spool/asterisk/monitorDONE/ORIG/ -maxdepth 2 -type f -mtime +2 -print | xargs rm -f

### remove all recordings more than 6 months old
30 0 * * * /usr/bin/find /var/spool/asterisk/monitorDONE/ -maxdepth 2 -type f -mtime +180 -print | xargs rm -f

### roll logs monthly on high-volume dialing systems
#30 1 1 * * /usr/share/astguiclient/ADMIN_archive_log_tables.pl

### remove old vicidial logs and asterisk logs more than 2 days old
28 0 * * * /usr/bin/find /var/log/astguiclient -maxdepth 1 -type f -mtime +2 -print | xargs rm -f
29 0 * * * /usr/bin/find /var/log/asterisk -maxdepth 3 -type f -mtime +2 -print | xargs rm -f
30 0 * * * /usr/bin/find / -maxdepth 1 -name "screenlog.0*" -mtime +4 -print | xargs rm -f
EOF
