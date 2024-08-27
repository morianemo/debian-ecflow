TAG=debian-eckit
all:
	docker build -t ${TAG} .
b:
	docker build -t ${TAG} .
pod:
	podman build --tag ${TAG} -f Dockerfile
pod-run:
	podman run ${TAG} ash
ash:
	docker run --net=host -ti ${TAG} bash
test:
	docker run --net=host -ti ${TAG} eckit-code-list
svr:
	docker run --net=host -ti ${TAG} ecflow_server --port 2500
view:
	xhost +
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${TAG} ecflow_ui
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif

ecbuild:
	docker build -f Dockerfile.ecbuild -t debian-ecbuild .
run-ecbuild:
	docker run  --net=host -ti -t debian-ecbuild bash
