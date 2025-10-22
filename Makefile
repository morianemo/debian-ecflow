CONT=debian-ecflow
LAST=ecflow-debian-last
ECF_PORT=3141
MNT = /home/ecflow/extern
STE = test
TAG = ${CONT}
NOSEC = --security-opt seccomp=unconfined
NET = host
# NET = debian-ecflow_default
HOST = localhost
# HOST = docker-debian-ecflow  # compose
# HOST =debian-ecflow_ecflow-server_1
SERVICE = ecflow-server
ADDHOST = --add-host=host.docker.internal:host-gateway
all:
	docker build -t ${CONT} .
as_ecflow:
	cd as_ecflow && docker -t debian-as-ecflow .
last:
	docker build -f Dockerfile.202408 -t ${LAST} .
pod:
	podman build --tag ${CONT} -f Dockerfile
pod-run:
	podman run ${CONT} ecflow_client --help
ash:
	docker run --net=${NET} -ti ${CONT} bash
mash:
	xhost +local:docker
	# docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} bash
	docker run -e DISPLAY --net=host -ti ${CONT} bash
ping:
	docker run --net=${NET} $(ADDHOST) -ti ${CONT} ecflow_client --ping --port ${ECF_PORT} --host $(HOST)
clt:
	docker run --net=${NET} -ti ${CONT} ecflow_client --help
	docker run --net=${NET} -ti ${CONT} ecflow_client --version
test:	clt svr
load:
	echo "suite ${STE}" > ${STE}.def
	echo "defstatus suspended" >> ${STE}.def
	echo "task run" >> ${STE}.def # we shall add head.h tail.h run.ecf
	docker run --net=${NET} -ti ${CONT} ecflow_client --port ${ECF_PORT} --delete=_all_ yes
	docker run --net=${NET} --volume $(PWD):${MNT} -ti ${CONT} ecflow_client --port ${ECF_PORT} --load ${MNT}/${STE}.def
	docker run --net=${NET} -ti ${CONT} ecflow_client --port ${ECF_PORT} --begin ${STE}
	docker run --net=${NET} -ti ${CONT} ecflow_client --port ${ECF_PORT} --halt yes
stop:
	docker run --net=${NET} -d -ti ${CONT} ecflow_stop.sh -p ${ECF_PORT}
server:
	docker run --net=${NET} -ti ${CONT} ecflow_server --port ${ECF_PORT}
viewl:
	xhost +local:docker
	docker run -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix --net=${NET} -ti ${CONT} ecflow_ui
svr: start
start:
	docker run --net=host -e ECFLOW_BINDIR=/usr/local/bin -ti ${TAG} /usr/local/bin//ecflow_start_nohup.sh -N -p ${ECF_PORT}
viewm:
	xhost +local:docker
	docker run -e DISPLAY=host.docker.internal:0 -v /tmp/.Xauthority:/tmp/.Xauthority --net=${NET} -ti ${CONT} ecflow_ui
view:
	xhost +local:docker
	docker run -e DISPLAY=host.docker.internal:0 --net=host -ti ${CONT} ecflow_ui
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
install-slim:
	brew install docker-slim
slim:
	slim build --target ${TAG}:latest --tag ${TAG}:light --http-probe=false --exec "ecflow_server --version; ecflow_client --help ; ecflow_ui --h; ecflow_client --version"
deploy:
	docker login
	docker tag ${TAG} eowyn/${TAG}:latest
	docker push eowyn/${TAG}
compose:
	docker-compose up -d
compose-down:
	docker-compose down
compose-ping:
	docker-compose exec $(SERVICE) ping -c 3 host.docker.internal
