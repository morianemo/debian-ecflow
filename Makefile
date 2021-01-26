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


BOOST = /usr/local/apps/boost/1.53.0/GNU/5.3.0
BOOST =  /opt/boost_1_71_0/stage
BOOST_INCLUDE_DIR = $(BOOST)/include
BOOST_LIB_DIR = $(BOOST)/lib
ECFLOW = ${HOME}/git/ecflow
SRCS = client-node.cpp  client.cpp
OBJS = $(SRCS:.cpp=.o)
mt=-mt

LECF=${HOME}/git/bdir/debug/ecflow
INCLUDEPATH = -I. -g -std=c++11 -Wall -pedantic \
  $(BOOST_INCLUDE) -I$(ECFLOW)/Client/src -I$(ECFLOW)/Base/src/cts \
  -I$(ECFLOW)/Base/src -I$(ECFLOW)/ANode/src -I$(ECFLOW)/ACore/src \
  -I$(ECFLOW)/ANattr/src
LPATH = -L${LECF} -g -std=c++11 -Wall -pedantic \
  -L${LECF}/Client -L${LECF}/Base/src/cts -L${LECF}/Base \
  -L${LECF}/ANode -L${LECF}/ACore -L${LECF}/ANattr
LIBS = -L. -DFO_BOOST_STATIC_LINK=TRUE -DBOOST_ALL_NO_LIB -DBOOST_ALL_DYN_LINK -DBOOST_LOG_DYN_LINK -g -std=c++11 -Wall -pedantic -L. -llibclient  -lbase -lnode -lnodeattr -lcore -L$(BOOST_LIB_DIR) -lboost_date_time -lboost_system${mt} -lboost_program_options -lboost_filesystem -lpthread -lboost_serialization${mt}  
CXXFLAGS = -g -std=c++11 -Wall -pedantic $(INCLUDEPATH)

# OBJS = client.cc client-node.cc

client.x: $(OBJS)
	g++ $(CXXFLAGS) $(INCLUDEPATH) -o $@ $(OBJS) ${LPATH} $(LIBS) 

.o.cc:
	g++ $(CXXFLAGS) -o $@ $<
