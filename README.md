# Generic Container Makefile

## Purpose

Provide a not-very-opinionated `Makefile` with simple targets for building and running containers

## Instructions

Either clone this repo, or copy the [Makefile](https://raw.githubusercontent.com/jhriv/generic-container-makefile/refs/heads/main/Makefile) to your project

## Usage

### Building the Image

- `make build`
- `make build CONTAINER_FILE=path/to/containerfile` to use a different container file
- `make build CONTAINER_CONTEXT=path/to/context` to use a different container context

## Running the Image

- `make run`
- `make root` run as a privledged user (passes `--user=root`)

## Compose Support

Only docker compose is supported.

- `up`
- `stop`
- `clean` stops the containers, removes orphans and volumes
- `veryclean` clean, and removes all images
- `console`

###
## Options

Automatically setting `IMAGE_*` requires docker being present

- `COMPOSE_FILE`
- `CONTAINER_CONTEXT`
- `CONTAINER_ENGINE`
- `CONTAINER_FILE`
- `CONTAINER_IMAGE`
- `CONTAINER_LIBRARY`
- `CONTAINER_NAME`
- `CONTAINER_REPO`
- `CONTAINER_TAG`
- `IMAGE_OSTYPE`
- `IMAGE_ARCHITECTURE`
- `IMAGE_PLATFORM`
