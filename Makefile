# Makefile
#
# build
#

-include    *.mk

BLD_ARG  ?= --build-arg DIST=nginx --build-arg REL=alpine
BLD_REPO ?= mlan/gitweb
BLD_VER  ?= latest
BLD_TGT  ?= full
BLD_TGTS ?= base full
BLD_CMT  ?= HEAD
BLD_DNLD ?= curl -o

TST_REPO ?= $(BLD_REPO)
TST_VER  ?= $(BLD_VER)
TST_ENV  ?= -C test
TST_TGTE ?= $(addprefix test-,all diff down env logs sh up)
TST_INDX ?= 1 2
TST_TGTI ?= $(addprefix test_,$(TST_INDX)) $(addprefix test-up_,$(TST_INDX))

export TST_REPO TST_VER

push:
	#
	# PLEASE REVIEW THESE IMAGES WHICH ARE ABOUT TO BE PUSHED TO THE REGISTRY
	#
	@docker image ls $(BLD_REPO)
	#
	# ARE YOU SURE YOU WANT TO PUSH THESE IMAGES TO THE REGISTRY? [yN]
	@read input; [ "$${input}" = "y" ]
	docker push --all-tags $(BLD_REPO)

build-all: $(addprefix build_,$(BLD_TGTS))

build: build_$(BLD_TGT)

build_%: pre_build
	docker build $(BLD_ARG) --target $* \
	$(addprefix --tag $(BLD_REPO):,$(call bld_tags,$*,$(BLD_VER))) .

pre_build: Dockerfile
	
variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

ps:
	docker ps -a

prune:
	docker image prune -f

clean:
	docker images | grep $(BLD_REPO) | awk '{print $$1 ":" $$2}' | uniq | xargs docker rmi

$(TST_TGTE):
	${MAKE} $(TST_ENV) $@

$(TST_TGTI):
	${MAKE} $(TST_ENV) $@
