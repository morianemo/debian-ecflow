CONT=debian-ecflow
LAST=ecflow-debian-last
PORT=2500
MNT = /home/ecflow/extern
STE = test
TAG = ${CONT}
all:
	docker build -t ${CONT} .
asecflow:
	cd as_ecflow && docker -t debian-as-ecflow .
last:
	docker build -f Dockerfile.202408 -t ${LAST} .
pod:
	podman build --tag ${CONT} -f Dockerfile
pod-run:
	podman run ${CONT} ecflow_client --help
ash:
	docker run --net=host -ti ${CONT} bash
clt:
	docker run --net=host -ti ${CONT} ecflow_client --help
test:	clt view svr
load:
	echo "suite ${STE}" > ${STE}.def
	echo "defstatus suspended" >> ${STE}.def
	echo "task run" >> ${STE}.def # we shall add head.h tail.h run.ecf
	docker run --net=host -ti ${CONT} ecflow_client --port ${PORT} --delete=_all_ yes
	docker run --net=host --volume $(PWD):${MNT} -ti ${CONT} ecflow_client --port ${PORT} --load ${MNT}/${STE}.def
	docker run --net=host -ti ${CONT} ecflow_client --port ${PORT} --begin ${STE}
	docker run --net=host -ti ${CONT} ecflow_client --port ${PORT} --halt yes
svr:
	docker run --net=host -ti ${CONT} ecflow_start.sh -p ${PORT}
server:
	docker run --net=host -ti ${CONT} ecflow_server --port ${PORT}
view:
	xhost +
        docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} ecflow_ui
	# docker run -e DISPLAY --net=host -ti ${CONT} ecflow_ui
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
install-slim:
	brew install docker-slim
slim:
	slim build --target ${TAG}:latest --tag ${TAG}:light --http-probe=false --exec "ecflow_server --version; ecflow_client --help ; ecflow_ui --h"
deploy:
	docker login
	docker tag ${TAG} eowyn/${TAG}:latest
	docker push eowyn/${TAG}
