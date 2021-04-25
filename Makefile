IMAGE=deweysasser/git-updater
CACHE=

image:
	DOCKER_BUILDKIT=1 docker build $(CACHE) -t $(IMAGE) .


scan:
	docker scan $(IMAGE)