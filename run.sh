#!/bin/bash
mkdir -p /usr/share/info/ /etc/alternatives/
wget -O /etc/yum.repos.d/goautodial.repo "http://downloads2.goautodial.org/centos/7/goautodial.repo"
yum install -y epel-release
yum update -y 
yum -y groupinstall "Development Tools" 

yum install -y httpd php-common php-pdo php php-pear php-mbstring php-cli php-gd php-imap php-devel \
phpsysinfo php-mysql phpmyadmin mod_ssl mariadb mariadb-server mariadb-devel perl-DBI perl-DBD-MySQL \
perl-Digest-HMAC perl-YAML perl-ExtUtils-ParseXS perl-NetAddr-IP perl-Crypt-SSLeay perl-Curses \
perl-DBD-Pg perl-Module-ScanDeps perl-Text-CSV perl-HTML-Template perl-IO-Compress perl-Text-Glob \
perl-Jcode perl-Test-Script perl-Archive-Tar perl-Test-Base perl-OLE-Storage_Lite perl-Archive-Zip \
perl-Net-Server perl-Convert-ASN1 perl perl-Compress-Raw-Zlib perl-Digest-SHA1 perl-Data-Dumper \
perl-Error perl-ExtUtils-CBuilder perl-Test-Tester perl-Parse-RecDescent perl-Spiffy perl-IO-Zlib \
perl-Module-Build perl-HTML-Parser perl-Net-SSLeay perl-Proc-ProcessTable perl-TermReadKey \
perl-Term-ReadLine-Gnu perl-Digest-SHA perl-Tk perl-Net-SNMP perl-Test-NoWarnings perl-XML-Writer \
perl-Proc-PID-File perl-Compress-Raw-Bzip2 perl-libwww-perl perl-XML-Parser perl-File-Remove \
perl-Parse-CPAN-Meta perl-Set-Scalar perl-Probe-Perl perl-File-Which perl-Package-Constants \
perl-Module-Install perl-File-HomeDir perl-Spreadsheet-ParseExcel perl-Mail-Sendmail perl-Spreadsheet-XLSX \
asterisk-perl perl-version perl-Crypt-DES perl-URI perl-Net-Daemon perl-IO-stringy perl-YAML-Tiny \
perl-HTML-Tagset perl-Socket6 perl-BSD-Resource perl-PlRPC perl-IPC-Run3 perl-Text-CSV_XS perl-Unicode-Map \
perl-Module-CoreList perl-Net-Telnet perl-PAR-Dist perl-Date-Manip perl-JSON perl-Proc-Daemon \
perl-Spreadsheet-WriteExcel perl-rrdtool install lame screen sox ntp iftop subversion asterisk \
asterisk-configs dahdi-tools dahdi-linux-devel php-xcache
#my added
yum install x11-devel
systemctl enable httpd.service; systemctl enable mariadb.service; systemctl start httpd.service; systemctl start mariadb.service

mysqlpass=$(openssl rand -hex 12)
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$mysqlpass');"
echo -e "[client]\nuser=root\npass=$mysqlpass\n" > /root/my.cnf

cpan install String::CRC Tk::TableMatrix Net::Address::IP::Local Term::ReadLine::Gnu Spreadsheet::Read \
Net::Address::IPv4::Local RPM::Specfile Spreadsheet::XLSX Spreadsheet::ReadSXC <<<yes
perl-Tk-TableMatrix

wget -O /usr/local/src/asterisk-perl-0.08.tar.gz http://asterisk.gnuinter.net/files/asterisk-perl-0.08.tar.gz
tar zxvf /usr/local/src/asterisk-perl-0.08.tar.gz
cd /usr/local/src/asterisk-perl-0.08
perl Makefile.PL && make all && make install

/usr/local/src/
wget http://downloads2.goautodial.org/centos/7/current/x86_64/RPMS/vicidial-2.9.441a-140612.1628.2.go.noarch.rpm
wget http://downloads2.goautodial.org/centos/7/current/x86_64/RPMS/goautodial-ce-3.3-1406088000.noarch.rpm
wget http://downloads2.goautodial.org/centos/7/current/x86_64/RPMS/goautodial-ce-config-3.3-1.noarch.rpm

rpm -ivh --nodeps vicidial-2.9.441a-140612.1628.2.go.noarch.rpm
rpm -ivh --nodeps goautodial-ce-3.3-1406088000.noarch.rpm
rpm -ivh --nodeps goautodial-ce-config-3.3-1.noarch.rpm
