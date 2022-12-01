# Makefile
#
# test
#

-include    *.mk

TST_REPO ?= mlan/gitweb
TST_VER  ?= latest
TST_NAME ?= test

TST_BIND ?= 127.0.0.1:8080
TST_INET ?= -p $(TST_BIND):80
TST_VOLS ?= -v $$(pwd)/../.git:/var/lib/git/repositories/docker-gitweb.git:ro
TST_ENVV ?= -e PROJECTS_LIST=

TST_W8UP ?= 1
TST_W8DN ?= 2

CNT_NAME ?= $(TST_NAME)-gui
CNT_LIST ?= gui

NET_SYSP := $(shell command -v nft)

ifdef NET_SYSP
	NET_RULE := nft list ruleset
else
	NET_RULE := iptables -t nat -nvL
endif

test-all: $(addprefix test_,1 2)
	
test_%: test-up_% test-waitu_% test-html_% test-down_% test-waitd_%
	
test-up_1:
	#
	#
	#
	# test (1) base, mount .git
	#
	#
	docker run --rm -d --name $(CNT_NAME) $(TST_ENVV) $(TST_VOLS) $(TST_INET) $(TST_REPO):$(call bld_tag,base,$(TST_VER))

test-up_2:
	#
	#
	#
	# test (2) full, mount .git
	#
	#
	docker run --rm -d --name $(CNT_NAME) $(TST_ENVV) $(TST_VOLS) $(TST_INET) $(TST_REPO):$(call bld_tag,full,$(TST_VER))

test-html_%:
	wget -O - $(TST_BIND) >/dev/null || false
	#
	#
	# test ($*) success ☺
	#
	#
	#

test-down_%:
	docker stop $(CNT_NAME) 2>/dev/null || true

test-waitu_%:
	sleep $(TST_W8UP)

test-waitd_%:
	sleep $(TST_W8DN)

test-up: test-up_1
	
test-html: test-html_0
	
test-down: test-down_0
	
$(addprefix test-,diff env htop logs sh nsrule nsss):
	${MAKE} $(patsubst test-%,gui-%,$@)

$(addsuffix -sh,$(CNT_LIST)):
	docker exec -it $(patsubst %-sh,$(TST_NAME)-%,$@) sh -c 'exec $$(getent passwd root | sed "s/.*://g")'

$(addsuffix -env,$(CNT_LIST)):
	docker exec -it $(patsubst %-env,$(TST_NAME)-%,$@) env

$(addsuffix -logs,$(CNT_LIST)):
	docker container logs $(patsubst %-logs,$(TST_NAME)-%,$@)

$(addsuffix -diff,$(CNT_LIST)):
	docker container diff $(patsubst %-diff,$(TST_NAME)-%,$@)

$(addsuffix -tools,$(CNT_LIST)):
	docker exec -it $(patsubst %-tools,$(TST_NAME)-%,$@) \
	apk --no-cache --update add \
	nano less lsof htop bind-tools iputils strace util-linux

$(addsuffix -htop,$(CNT_LIST)):
	docker exec -it $(patsubst %-htop,$(TST_NAME)-%,$@) htop

$(addsuffix -nsrule,$(CNT_LIST)):
	sudo nsenter -n -t $(call dkr_cnt_pid,$(patsubst %-nsrule,$(TST_NAME)-%,$@)) $(NET_RULE)

$(addsuffix -nsss,$(CNT_LIST)):
	sudo nsenter -n -t $(call dkr_cnt_pid,$(patsubst %-nsss,$(TST_NAME)-%,$@)) ss -utnlp

