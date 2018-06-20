FROM 	nginx:alpine

LABEL 	maintainer=mlan

RUN	apk --no-cache --update add \
	git-gitweb \
	fcgiwrap \
	spawn-fcgi

COPY	etc/nginx/conf.d/gitweb.conf /etc/nginx/conf.d/.
COPY	etc/gitweb.conf /etc/.
COPY	entrypoint.sh /usr/local/bin/.

EXPOSE  80

CMD 	["entrypoint.sh"]
