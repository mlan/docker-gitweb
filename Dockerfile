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

ENV	DOCKER_ENTRY_DIR=/etc/entrypoint.d \
	PROJECTROOT=/var/lib/git/repositories \
	PROJECTS_LIST=/var/lib/git/projects.list

#
# Copy config files to image
#

COPY	src/git-gitweb_base.template /tmp/git-gitweb.template
COPY	src/nginx-gitweb.conf /etc/nginx/conf.d/gitweb.conf
COPY	src/entrypoint.sh /usr/local/bin/
COPY	src/entrypoint.d $DOCKER_ENTRY_DIR/

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
	&& mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.dist

#
# state standard http port
#

EXPOSE	80

#
# Rudimentary healthcheck
#

HEALTHCHECK CMD nginx -t &>/dev/null && wget -O - localhost:80 &>/dev/null \
	|| exit 1

#
# Entrypoint, how container is run
#

ENTRYPOINT	["entrypoint.sh"]

CMD	["nginx", "-g", "daemon off;"]


#
#
# target: full
#
# add highlight
#
#

FROM	base AS full

#
# Copy config files to image
#

COPY	src/git-gitweb_full.template /tmp/git-gitweb.template

#
# Install
#

RUN	apk --no-cache --update add \
	highlight
