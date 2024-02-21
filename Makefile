# always get the filename of this file
override WHOAMI := $(lastword $(MAKEFILE_LIST))

# per project overrides
include $(wildcard .make.env)

# these can inherit from the environment
COMPOSE_FILE ?= $(firstword $(wildcard compose.yaml compose.yml docker-compose.yaml docker-compose.yml))
CONTAINER_CONTEXT ?= $(dir $(realpath $(WHOAMI)))
CONTAINER_ENGINE ?= $(shell /usr/bin/which podman || /usr/bin/which docker || echo false)
CONTAINER_FILE ?= $(firstword $(wildcard Containerfile Dockerfile))
CONTAINER_IMAGE ?= $(notdir $(PWD))
CONTAINER_LIBRARY ?= $(shell id -un)
CONTAINER_NAME ?= $(CONTAINER_IMAGE)
CONTAINER_REPO ?= docker.io
CONTAINER_TAG ?= latest
IMAGE_OSTYPE ?= $(shell docker info --format '{{ .OSType }}')
IMAGE_ARCHITECTURE ?= $(shell docker info --format '{{ .Architecture }}')
IMAGE_PLATFORM ?= $(IMAGE_OSTYPE)/$(IMAGE_ARCHITECTURE)
TAG ?= $(CONTAINER_REPO)/$(CONTAINER_LIBRARY)/$(CONTAINER_IMAGE):$(CONTAINER_TAG)
_SOURCE_REPOSITORY ?= https://raw.githubusercontent.com/jhriv/generic-container-makefile/main


init: .make.env Dockerfile compose.yaml

Dockerfile compose.yaml:
	@wget --quiet --output-document=$@ $(_SOURCE_REPOSITORY)/$@.sample
	@echo "$@ sample downloaded"

# this is probably overly complicated and convoluted
# find all the variables defined with ?=, print the name and the calculated
# value into a file that will be subsequently sourced
.make.env:
	@( echo '# Uncomment and change as needed'; \
	   echo; \
	   sed -nE 's/([A-Z_]+) \?=.*/\1/p' $(realpath $(WHOAMI)) \
		| while read V; do \
			echo "# $$V := $$($(MAKE) -f $(WHOAMI) V=$$V _print_var)"; \
		done ) > $@
	@echo "$@ created with default values"

.PHONY: _print_var
_print_var:
	@echo $($V)

.PHONY: build
build:
	@$(CONTAINER_ENGINE) build \
		--file $(CONTAINER_FILE) \
		--platform $(IMAGE_PLATFORM) \
		--tag $(TAG) \
		$(CONTAINER_CONTEXT)

.PHONY: run
run:
	@$(CONTAINER_ENGINE) run \
		--hostname $(CONTAINER_NAME) \
		--interactive \
		--name $(CONTAINER_NAME) \
		--tty \
		${TAG}

.PHONY: root
root:
	@$(CONTAINER_ENGINE) run \
		--hostname $(CONTAINER_NAME) \
		--interactive \
		--name $(CONTAINER_NAME) \
		--tty \
		--user=root \
		${TAG}

.PHONY: up
up:
	@$(CONTAINER_ENGINE) compose --file $(COMPOSE_FILE) up

.PHONY: stop
stop:
	@$(CONTAINER_ENGINE) compose --file $(COMPOSE_FILE) stop

.PHONY: clean
clean:
	@$(CONTAINER_ENGINE) compose --file $(COMPOSE_FILE) down --remove-orphans --volumes

.PHONY: veryclean
veryclean:
	@$(CONTAINER_ENGINE) compose --file $(COMPOSE_FILE) down --remove-orphans --volumes --rmi all

.PHONY: console
console:
	@$(CONTAINER_ENGINE) compose --file $(COMPOSE_FILE) run --rm $(NAME) /bin/bash
