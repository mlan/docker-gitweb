-include    *.mk

BLD_ARG  ?= --build-arg DIST=nginx --build-arg REL=alpine
BLD_REPO ?= mlan/gitweb
BLD_VER  ?= latest
BLD_TGT  ?= full

IMG_REPO ?= $(BLD_REPO)
IMG_VER  ?= $(BLD_VER)
_version  = $(if $(findstring $(BLD_TGT),$(1)),$(2),$(if $(findstring latest,$(2)),$(1),$(1)-$(2)))
_ip       = $(shell docker inspect -f \
	'{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' \
	$(1) | head -n1)

TST_NAME ?= test-gitweb
TST_BIND ?= 127.0.0.1:8080
TST_INET ?= -p $(TST_BIND):80
TST_VOLS ?= -v $$(pwd)/.git:/var/lib/git/repositories/docker-gitweb.git:ro
TST_ENVV ?= -e PROJECTS_LIST=

.PHONY:

build-all: build_base build_full

build: depends
	docker build $(BLD_ARG) --target $(BLD_TGT) -t $(BLD_REPO):$(BLD_VER) .

build_%: depends
	docker build $(BLD_ARG) --target $* -t $(BLD_REPO):$(call _version,$*,$(BLD_VER)) .

depends: Dockerfile

test-all: test_1
	
test_%: test-up_% test-html_% test-down_%
	
test-up_1:
	#
	# test (1) mount .git
	#
	docker run --rm -d --name $(TST_NAME) $(TST_ENVV) $(TST_VOLS) $(TST_INET) $(IMG_REPO):$(IMG_VER)

test-html_%:
	wget -O - $(TST_BIND) >/dev/null || false
	#
	# test ($*) success
	#

test-down_%:
	docker stop $(TST_NAME) 2>/dev/null || true

test-up: test-up_1
	
test-html: test-html_0
	
test-down: test-down_0
	

variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

prune:
	docker image prune -f

prune-all:
	docker image prune
	docker container prune
	docker volume prune
	docker network prune

