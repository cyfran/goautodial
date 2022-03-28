FROM centos:7
MAINTAINER Fortest <fortest@test.com>
LABEL Description="goautodial test"
RUN wget https://raw.githubusercontent.com/cyfran/goautodial/main/install.sh
RUN bash install.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
CMD ["/run.sh"]
