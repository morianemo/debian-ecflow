FROM debian:bookworm

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8 \
  && apt-get install -y build-essential cmake python3-dev qtbase5-dev \
    libmotif-dev libx11-dev libxext-dev libxpm-dev vim fvwm libxt-dev \
    xvfb wget \
  && apt-get install -qqy x11-apps

WORKDIR /tmp

ENV DBUILD=/tmp/eckit_build
RUN mkdir ${DBUILD}
RUN mkdir -p /tmp/build

RUN apt-get install -y unzip git

RUN export ETGZ=eckit.zip HTTPE=https://confluence.ecmwf.int/download/attachments/8650755/ecFlow-5.12.0-Source.tar.gz?api=v2 \
    && cd ${DBUILD} \
    && wget -O ${ETGZ} https://github.com/ecmwf/eckit/archive/refs/heads/develop.zip && unzip ${ETGZ}

RUN ln -sf ${DBUILD}/eckit-develop ${DBUILD}/eckit-${VERSION}-Source

RUN cd ${DBUILD} && wget -O ecbuild.zip \
  https://github.com/ecmwf/ecbuild/archive/refs/heads/develop.zip && \
  unzip ecbuild.zip
RUN cd ${DBUILD}/ecbuild-develop && mkdir build && cd build && cmake ../ && make -j2 && make install

RUN export WK=${DBUILD}/eckit-${VERSION}-Source
RUN cd ${BUILD} && git clone https://github.com/ecmwf/eckit.git

RUN cd ${DBUILD}/eckit-develop && mkdir -p build && cd build && cmake .. && make && make install
RUN apt install -y bison flex liblz4-dev libblas-dev liblapack-dev curl doxygen
RUN cd ${DBUILD}/ecbuild-develop && mkdir -p build && cd build && cmake ../ && make -j2 && make install

ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=eckit \
    LANG=C \
    PYTHONPATH=/usr/local/lib/python3/site-packages
