#colors:
B = \033[1;94m#   BLUE
G = \033[1;92m#   GREEN
Y = \033[1;93m#   YELLOW
R = \033[1;31m#   RED
M = \033[1;95m#   MAGENTA
K = \033[K#       ERASE END OF LINE
D = \033[0m#      DEFAULT
A = \007#         BEEP

.PHONY: build start dev stop test mocks lint

SHELL := /bin/bash
APP=$(shell basename -s .git $(shell git remote get-url origin))
REGISTRY=ghcr.io/obezsmertnyi
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
BASEDIR = ./snapshot/*.tar.zst
BASEPATH=${REGISTRY}/${APP}:${VERSION}

build:
	@echo -e "${M}Building Docker image for ${APP}${D}"
	@echo -e "${Y}Pulling the latest base image: c29r3/solana-snapshot-finder:latest${D}"
	@docker pull c29r3/solana-snapshot-finder:latest || { echo -e "${R}Error: Failed to pull the base image.${D}"; exit 1; }
	@echo -e "${Y}Building ${APP} image version: ${VERSION}${D}\n"
	@docker build -f Dockerfile . -t ${BASEPATH} || { echo -e "${R}Error: Build failed.${D}"; exit 1; }
	@echo -e "${G}Build completed successfully! Image: ${BASEPATH}${D}"

push:
	@echo -e "${M}Pushing Docker image to the registry: ${BASEPATH}${D}"
	@docker push ${BASEPATH} || { echo -e "${R}Error: Failed to push the image.${D}"; exit 1; }
	@echo -e "${G}Image pushed successfully!${D}"

clean:
	@echo -e "${M}Cleaning up Docker images created for ${APP} version ${VERSION}...${D}"
	@if docker images ${BASEPATH} -q | grep -q '.' ; then \
		echo -e "${Y}Removing Docker image ${BASEPATH}${D}"; \
		docker rmi ${BASEPATH} || { echo -e "${R}Error: Failed to remove the image.${D}"; exit 1; } \
	else \
		echo -e "${R}No Docker image found for ${BASEPATH}${D}"; \
	fi
	@echo -e "${G}Cleanup completed for ${APP} version ${VERSION}!${D}"

download:
	@rm -f ./snapshot/*
	@mkdir -p ./snapshot
	@docker run -it --rm -v $(PWD)/snapshot:/snapshot --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /snapshot

stream:
	for f in $(shell ls ${BASEDIR}); do echo $$(realpath $${f}) && docker run -p 3000:3000 --rm -it --mount type=bind,source=$$(realpath $${f}),target=$$(realpath $${f}),readonly --mount type=bind,source=$$(pwd)/geyser-conf.json,target=/app/geyser-conf.json,readonly ${BASEPATH} $$(realpath $${f}) --geyser=./geyser-conf.json && date; done