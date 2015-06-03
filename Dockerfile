FROM debian:wheezy
MAINTAINER ncg09@hampshire.edu

ENV DEBIAN_FRONTEND noninteractive

COPY start.sh /
COPY uwsgi.ini /
COPY shell.sh /

RUN apt-get update \
  && apt-get install -y python-pip python-dev python-mysqldb git subversion mercurial python-svn \
  && easy_install reviewboard \
  && pip install -U uwsgi \
  && chmod +x /start.sh /shell.sh

VOLUME ["/.ssh", "/media/"]

EXPOSE 8000

CMD /start.sh
