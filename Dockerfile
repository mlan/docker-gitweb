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

ENV	DOCKER_ENTRY_DIR=/etc/docker/entry.d \
	DOCKER_BIN_DIR=/usr/local/bin \
	DOCKER_CONF_DIR=/etc/nginx/conf.d \
	DOCKER_ENVSUBST_DIR=usr/share/misc \
	DOCKER_HIGHLIGHT_CMT='#' \
	PROJECTROOT=/var/lib/git/repositories \
	PROJECTS_LIST=/var/lib/git/projects.list \
	SERVER_NAME=localhost

#
# Copy config files to image
#

COPY	src/*/bin $DOCKER_BIN_DIR/
COPY	src/*/entry.d $DOCKER_ENTRY_DIR/
COPY	src/*/envsubst $DOCKER_ENVSUBST_DIR/

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
# state standard http port 80
#

EXPOSE	80

#
# Rudimentary healthcheck
#

HEALTHCHECK CMD curl -so /dev/null http://localhost/ || exit 1

#
# Entrypoint, how container is run
#

ENTRYPOINT	["docker-entrypoint.sh"]

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
# Enable highlight
#

ENV	DOCKER_HIGHLIGHT_CMT=

#
# Install
#

RUN	apk --no-cache --update add \
	highlight \
	git-daemon
