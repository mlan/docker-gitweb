-include    *.mk .env

_ip       = $(shell docker inspect -f \
	'{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' \
	$(1) | head -n1)

SRV_NAME ?= repo-gui
CNT_NAME ?= $(COMPOSE_PROJECT_NAME)-$(SRV_NAME)-1
CNT_BIND ?= 127.0.0.1:8080
CNT_SHEL ?= sh
TST_WEBB ?= firefox

variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

init: up

ps:
	docker compose ps

up:
	docker compose up -d

start:
	docker compose start

stop:
	docker compose stop

down:
	docker compose down

destroy:
	docker compose down -v

config:
	docker compose config

wait_%:
	sleep 10

web:
	$(TST_WEBB) $(CNT_BIND) &

log:
	docker container logs $(CNT_NAME)

logs:
	docker compose logs --tail 10

sh:
	docker compose exec $(SRV_NAME) $(CNT_SHEL)

diff:
	docker container diff $(CNT_NAME)

top:
	docker container top $(CNT_NAME)

env:
	docker compose exec $(SRV_NAME) env

htop: tools_install
	docker compose exec $(SRV_NAME) htop

ipcs:
	docker compose exec $(SRV_NAME) ipcs

apk_list:
	docker compose exec $(SRV_NAME) /bin/sh -c 'for pkg in $$(apk info 2>/dev/null); do printf "%9s  %s\n" $$(apk info -s $$pkg 2>/dev/null | sed -n "2{p;q}") $$pkg; done | sort'

apk_add_%:
	docker compose exec $(SRV_NAME) apk -q --no-cache --update add $*

tools_install:
	docker compose exec $(SRV_NAME) apk --no-cache --update add \
	nano lsof htop openldap-clients bind-tools iputils strace util-linux

theme_kogakure:
	docker compose exec $(SRV_NAME) sh -c 'git clone https://github.com/kogakure/gitweb-theme.git /tmp/gitweb-theme && apk --no-cache --update add bash && cd /tmp/gitweb-theme && ./setup --install'

