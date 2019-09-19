-include    *.mk

BLD_ARG  ?= --build-arg DIST=nginx --build-arg REL=alpine
BLD_REPO ?= mlan/gitweb
BLD_VER  ?= latest

IMG_REPO ?= $(BLD_REPO)
IMG_VER  ?= $(BLD_VER)
IMG_CMD  ?= /bin/sh

TST_NAME ?= test-gitweb
TST_PORT ?= localhost:8080
TST_INET ?= -p $(TST_PORT):80
TST_DIR  ?= test/repo
TST_REPO ?= mlan/docker-gitweb
TST_VOLS ?= -v $(shell pwd)/$(TST_DIR):/var/lib/git:ro
TST_WEBB ?= firefox
TST_XTRA ?= --cap-add SYS_PTRACE

.PHONY: build build-all

build-all: build

build: Dockerfile
	docker build $(BLD_ARG) --target base -t $(BLD_REPO):$(BLD_VER) .

build_%: Dockerfile
	docker build $(BLD_ARG) --target $* -t $(BLD_REPO):$(call _ver,$(BLD_VER),$*) .

variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

ps:
	docker ps -a

prune:
	docker image prune
	docker container prune
	docker volume prune
	docker network prune

test-all: test_1
	
test_%: test-up_% test-html_% test-down_%
	
test-up_1: $(TST_DIR)/repositories/$(TST_REPO).git
	#
	# test (1) basic
	#
	docker run --rm -d --name $(TST_NAME) $(TST_VOLS) $(TST_INET) $(TST_XTRA) $(IMG_REPO):$(IMG_VER)

test-up_2: $(TST_DIR)/repositories/$(TST_REPO).git
	#
	# test (2) basic PROJECTS_LIST=
	#
	docker run --rm -d --name $(TST_NAME) -e PROJECTS_LIST= $(TST_VOLS) $(TST_INET) $(TST_XTRA) $(IMG_REPO):$(IMG_VER)

test-up_3:
	#
	# test (3) basic existing repo
	#
	docker run --rm -d --name $(TST_NAME) $(TST_VOLS) $(TST_INET) $(TST_XTRA) $(IMG_REPO):$(IMG_VER)

test-html_%:
	wget -O - $(TST_PORT) >/dev/null || false
	#
	# test ($*) success
	#

test-down_%:
	docker stop $(TST_NAME) 2>/dev/null || true

test-up: test-up_1
	
test-html: test-html_0
	
test-down: test-down_0
	rm -rf $(TST_DIR)

test-web:
	$(TST_WEBB) $(TST_PORT) &

$(TST_DIR)/projects.list:
	mkdir -p $(TST_DIR)/repositories
	echo $(TST_REPO).git > $(TST_DIR)/projects.list

$(TST_DIR)/repositories/$(TST_REPO).git: $(TST_DIR)/projects.list
	git clone --bare https://github.com/$(TST_REPO).git \
		$(TST_DIR)/repositories/$(TST_REPO).git

test-logs:
	docker container logs $(TST_NAME)

test-cmd:
	docker exec -it $(TST_NAME) $(IMG_CMD)

test-diff:
	docker container diff $(TST_NAME)

test-theme-kogakure:
	docker exec -it $(TST_NAME) sh -c 'git clone https://github.com/kogakure/gitweb-theme.git /tmp/gitweb-theme && apk --no-cache --update add bash && cd /tmp/gitweb-theme && ./setup --install'
	
test-htop: test-debugtools
	docker exec -it $(TST_NAME) htop

test-debugtools:
	docker exec -it $(TST_NAME) apk --no-cache --update add \
	nano less lsof htop openldap-clients bind-tools iputils strace

	
