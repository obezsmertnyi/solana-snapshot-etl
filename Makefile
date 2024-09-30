.PHONY: build start dev stop test mocks lint

SHELL := /bin/bash
BASEDIR = ./snapshot/*.tar.zst

export IMAGE_NAME=solana-snapshot-etl

build:
	@docker pull c29r3/solana-snapshot-finder:latest
	@docker build -f Dockerfile . -t ${IMAGE_NAME}

download:
	@rm -f ./snapshot/*
	@mkdir -p ./snapshot
	@docker run -it --rm -v $(PWD)/snapshot:/snapshot --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /snapshot

stream:
	for f in $(shell ls ${BASEDIR}); do echo $$(realpath $${f}) && docker run -p 3000:3000 --rm -it --mount type=bind,source=$$(realpath $${f}),target=$$(realpath $${f}),readonly --mount type=bind,source=$$(pwd)/geyser-conf.json,target=/app/geyser-conf.json,readonly ${IMAGE_NAME} $$(realpath $${f}) --geyser=./geyser-conf.json && date; done