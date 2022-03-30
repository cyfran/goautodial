FROM centos:7
MAINTAINER Fortest <fortest@test.com>
LABEL Description="goautodial test"
RUN yum install -y wget
RUN wget https://raw.githubusercontent.com/cyfran/goautodial/main/install.sh
RUN bash install.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
ENV JELASTIC_EXPOSE=FALSE
CMD ["/run.sh"]

