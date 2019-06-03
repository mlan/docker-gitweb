ARG	DIST=nginx
ARG	REL=alpine


#
#
# target: base
#
# gitweb only
#
#

FROM	$DIST:$REL AS base
LABEL	maintainer=mlan

#
# Copy config files to image
#

COPY	src/git-gitweb.conf /etc/gitweb.conf
COPY	src/nginx-gitweb.conf /etc/nginx/conf.d/gitweb.conf

#
# Install
#
# move away default nginx configuration
#

RUN	apk --no-cache --update add \
	git-gitweb \
	perl-cgi \
	fcgiwrap \
	spawn-fcgi \
	&& mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.off

#
# state standard http port
#

EXPOSE	80

#
# Rudimentary healthcheck
#

HEALTHCHECK CMD nginx -t &>/dev/null && wget -O - localhost:80 &>/dev/null || exit 1

#
# Entrypoint, how container is run
#

CMD	spawn-fcgi -s /var/run/fcgiwrap.socket -M 0666 -u nginx -- /usr/bin/fcgiwrap && \
	nginx -g "daemon off;"
