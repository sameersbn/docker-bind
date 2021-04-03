all: build

build:
	@docker build --tag=windoac/bind-webmin:latest .
