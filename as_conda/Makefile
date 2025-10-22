CONT = ecflow-as-conda
TAG = ${CONT}
ECF_PORT = 3141
HOST = localhost
# HOST = docker-debian-ecflow  # compose
all: as_conda

as_conda:
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
	docker run --net=host -ti ${CONT} ecflow_client --ping --port ${ECF_PORT} --host ${HOST}
clt:
	docker run --net=host -ti ${CONT} ecflow_client --help
	docker run --net=host -ti ${CONT} ecflow_client --version
stop:
	docker run --net=host -ti ${CONT} bash /opt/conda/bin/ecflow_stop.sh -p ${ECF_PORT}
svr:
	docker run --net=host -ti ${CONT} /opt/conda/bin/ecflow_start.sh -p ${ECF_PORT} 
server:
	docker run --net=host -e ECFLOW_BINDIR=/opt/conda/bin -ti ${CONT} /opt/conda/bin/ecflow_start_nohup.sh -N -p ${ECF_PORT}
echo:
	docker run --net=host -e ECFLOW_BINDIR=/opt/conda/bin -ti ${CONT} 'echo ${ECFLOW_BINDIR}'
viewm: 
	xhost +local:docker
	docker run -e DISPLAY --net=host -ti ${CONT} ecflow_ui  # linux
svr: start
start:
	docker run --net=host -e ECFLOW_BINDIR=/opt/conda/bin -ti ${TAG} /opt/conda/bin/ecflow_start_nohup.sh -N -p ${ECF_PORT}
xhost:
	xhost +local:docker
viewl:
	xhost +local:docker
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} /opt/conda/bin/ecflow_ui
mash:
	xhost +local:docker
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} bash
test:	clt svr
deploy:
	docker login
	docker tag ${CONT} eowyn/${CONT}:latest
	docker push eowyn/${CONT}
compose:
	docker-compose up -d
compose-down:
	docker-compose down
