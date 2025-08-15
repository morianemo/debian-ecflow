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
ash:
	#	docker run --net=host -ti ${CONT} bash
