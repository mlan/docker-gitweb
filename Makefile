include make_env

NS ?= mlan
VERSION ?= latest

IMAGE_NAME ?= gitweb
CONTAINER_NAME ?= gitweb
CONTAINER_INSTANCE ?= default
SHELL ?= /bin/sh

.PHONY: build  build-force shell exec run run-fg start stop rm-container rm-image purge create sleep

build: 
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

build-force: stop purge build

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) $(SHELL)

exec:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(SHELL)

run-fg:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

run:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start:
	docker start $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm-container:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm-image:
	docker image rm $(NS)/$(IMAGE_NAME):$(VERSION)


create:
	docker create --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)


purge: rm-container rm-image

sleep:
	sleep 3

default: build


