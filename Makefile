CONT=ecflow-debian
LAST=ecflow-debian-last
PORT=2500
MNT = /home/ecflow/extern
STE = test
all:
	docker build -t ${CONT} .
last:
	docker build -f Dockerfile.202209 -t ${LAST} .
pod:
	podman build --tag ${CONT} -f Dockerfile
pod-run:
	podman run ${CONT} ecflow_client --help
ash:
	docker run --net=host -ti ${CONT} bash
clt:
	dockerrun --net=host -ti ${CONT} ecflow_client --help
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
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
