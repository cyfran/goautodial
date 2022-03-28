FROM      centos:7
MAINTAINER Fortest <fortest@test.com>
LABEL Description="goautodial test"
ADD run.sh /run.sh
RUN chmod +x /*.sh
CMD ["/run.sh"]
