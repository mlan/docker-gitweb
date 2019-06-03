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
TST_VOLS ?= -v $(shell pwd)/test/repo:/var/lib/git:ro

.PHONY: build build-all

build-all: build

build: Dockerfile
	docker build $(BLD_ARG) --target base -t $(BLD_REPO):$(BLD_VER) .

build-base: Dockerfile
	docker build $(BLD_ARG) --target base -t $(BLD_REPO):$(call _ver,$(BLD_VER),base) .

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
	
test-up_1: test/repo/repositories/mlan/docker-gitweb.git
	#
	# test (1) basic
	#
	docker run --rm -d --name $(TST_NAME) $(TST_VOLS) $(TST_INET) $(IMG_REPO):$(IMG_VER)

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
	rm -rf test/repo

test/repo/projects.list:
	mkdir -p test/repo/repositories
	echo mlan/docker-gitweb.git > test/repo/projects.list

test/repo/repositories/mlan/docker-gitweb.git: test/repo/projects.list
	git clone --bare https://github.com/mlan/docker-postfix-amavis.git \
		test/repo/repositories/mlan/docker-gitweb.git

test-logs:
	docker container logs $(TST_NAME)

test-cmd:
	docker exec -it $(TST_NAME) $(IMG_CMD)

test-diff:
	docker container diff $(TST_NAME)

