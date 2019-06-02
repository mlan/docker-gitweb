FROM	nginx:alpine

LABEL	maintainer=mlan

RUN	apk --no-cache --update add \
	git-gitweb \
	fcgiwrap \
	spawn-fcgi \
	perl-cgi

COPY	etc/nginx/conf.d/gitweb.conf /etc/nginx/conf.d/.
COPY	etc/gitweb.conf /etc/.
RUN	mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.off

EXPOSE  80

CMD	spawn-fcgi -s /var/run/fcgiwrap.socket -M 0666 -u nginx -- /usr/bin/fcgiwrap && \
	nginx -g "daemon off;"
