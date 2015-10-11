all: build

build:
	@docker build --tag=quay.io/sameersbn/bind .
