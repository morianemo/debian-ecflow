TAG=debian-eckit
all:
	docker build -t ${TAG} .
pod:
	podman build --tag ${TAG} -f Dockerfile
pod-run:
	podman run ${TAG} ash
ash:
	docker run --net=host -ti ${TAG} bash
test:
	docker run --net=host -ti ${TAG} eckit-codec-list
