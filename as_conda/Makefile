CONT = ecflow-as-conda
all: asconda

asconda:
	docker build -t ${CONT} .
mac:
	xhost +
	@echo '# launching container: run ecflow_ui from there'
	@echo '# ecflow_start.sh -p 3141'
	@echo '# ecflow_client --ping'
	@echo '# ecflow_ui &'
	@echo '# python3 -c "import ecflow; help(ecflow)"'
	docker run -e DISPLAY=host.docker.internal:0 --net=host -ti ${CONT} bash
linux:
	xhost +local:docker  # Permet à Docker d'accéder à X11
	docker run -it \
    --env="DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
     --net=host -ti ${CONT} bash
eyes:
	podman run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ferri/xeyes:alpine
ash:
	#	docker run --net=host -ti ${CONT} bash
deploy:
	docker login
	docker tag ${CONT} eowyn/${CONT}:latest
	docker push eowyn/${CONT}
