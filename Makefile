CONT=ecflow-debian

all:
	docker build -t ${CONT} .

ash:
	docker run --net=host -ti ${CONT} bash

clt:
	docker run --net=host -ti ${CONT} ecflow_client --help

svr:
	docker run --net=host -ti ${CONT} ecflow_server --port 2500

view:
	xhost +
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} ecflowview
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} ecflow_ui

conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
