CONT = ecflow-as-conda
PORT = 3141
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
	xhost +local:docker  # allow Docker to access X11
	docker run -it \
    --env="DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
     --net=host -ti ${CONT} bash
eyes:
	podman run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ferri/xeyes:alpine
ash:
	docker run --net=host -ti ${CONT} bash
ping:
	docker run --net=host -ti ${CONT} ecflow_client --ping --port ${PORT}
clt:
	docker run --net=host -ti ${CONT} ecflow_client --help
stop:
	docker run --net=host -ti ${CONT} /opt/conda/bin/ecflow_stop.sh -p ${PORT}
svr:
	docker run --net=host -ti ${CONT} /opt/conda/bin/ecflow_start.sh -p ${PORT}
	# docker run --net=host -e ECFLOW_DIR -v /opt/conda/bin/ -ti ${CONT} bash /opt/conda/bin/ecflow_start.sh -p ${PORT}
lview:
	xhost +local:docker
	docker run -e DISPLAY --net=host -ti ${CONT} ecflow_ui  # linux
mview:
	xhost +local:docker
        docker run -e DISPLAY=host.docker.internal:0 -v /tmp/.Xauthority:/tmp/.Xauthority  --net=host -ti ${CONT} ecflow_ui
test:	clt mview svr
deploy:
	docker login
	docker tag ${CONT} eowyn/${CONT}:latest
	docker push eowyn/${CONT}
compose:
	docker-compose up -d
compose-down:
	docker-compose down
