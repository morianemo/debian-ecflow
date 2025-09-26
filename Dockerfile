FROM debian:trixie

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

# variables used for compilation, they can be removed after the built
ENV WK=/tmp/ecflow_build/ecFlow-Source \
    BOOST_ROOT=/usr \
    BR=/tmp/ecflow_build/boost_1_71_0 TB=boost_1_71_0.tar.gz \
    COMPILE=0 \
    HTTPB=https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/${TB} \
    HTTP=https://confluence.ecmwf.int/download/attachments/8650755

RUN mkdir -p ${WK}/build
RUN rm -rf /tmp/ecflow_build
RUN mkdir -p /tmp/ecflow_build
RUN ln -sf /usr/lib/x86_64-linux-gnu /usr/lib64
RUN apt-get -y update --fix-missing
RUN apt-get -y install --fix-missing apt-utils qtscript5-dev libssl-dev unzip
ENV PATH=/root/bin:$PATH CMAKE_MODULE_PATH=/root/cmake:/root

RUN apt-get -y install libqt5widgets5 libqt5network5 libqt5gui5 libqt5svg5-dev libqt5charts5-dev doxygen
RUN cd  ${DBUILD} && wget -O ecbuild.zip \
  https://github.com/ecmwf/ecbuild/archive/refs/heads/develop.zip && \
  unzip ecbuild.zip && \
  cd ecbuild-* && mkdir build && cd build # && cmake ../ && make && make install
    
RUN apt-get -y install libboost1.83-all libboost1.83-all-dev
ENV BOOST_ROOT=/usr
RUN apt-get -y install git
RUN mkdir -p ${WK} && cd ${WK} && git clone https://github.com/ecmwf/ecflow.git && cd ecflow && mkdir -p build && cd build
RUN sed -i "s| Boost ${ECFLOW_BOOST_VERSION} REQUIRED| Boost REQUIRED |g" ${WK}/ecflow/CMakeLists.txt
RUN sed -i "70i set ( ENABLE_STATIC_BOOST_LIBS OFF) " ${WK}/ecflow/CMakeLists.txt
RUN sed -i "14i find_package( Boost ) " ${WK}/ecflow/CMakeLists.txt
RUN sed -i '/^[^#]/ s/\(^.*set(ECFLOW_BOOST_VERSION.*$\)/#\ \1/' ${WK}/ecflow/CMakeLists.txt
RUN apt-get -y install libboost1.83-dev git
RUN apt-get update && apt-get install -y libboost1.83-all-dev
RUN apt-get -y install libboost1.83-dev git # && apt install libboost-timer
RUN apt-get update && apt-get install -y cmake build-essential
RUN cd ${WK}/ecflow/build && cmake -DBOOST_ROOT=/usr -B . -S .. || :
RUN cd ${WK}/ecflow/build && cmake -DBOOST_ROOT=/usr -B . -S .. && make -j2 && make install
ENV TE=ecFlow-5.14.1-Source.tar.gz
RUN cd /tmp/ecflow_build && wget --output-document=${TE} ${HTTP}/${TE}?api=v2 && tar -xzvf ${TE}
RUN cd ${WK}/ecflow/build && cmake .. -DCMAKE_MODULE_PATH=/root/cmake -DENABLE_UI=ON
RUN apt install -y rsync
# environment variables for ecFlow server
ENV ECFLOW_USER=ecflow \
    ECF_PORT=3141 \
    ECF_HOME=/home/ecflow/ecflow_server \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=en_US.UTF-8 \
    PYTHONPATH=/usr/local/lib/python3.8/site-packages

EXPOSE ${ECF_PORT}

RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ecflow /home/ecflow && chgrp ecflow /home/ecflow
USER ecflow
WORKDIR /home/ecflow
ENV DISPLAY=:0
ENV TE=ecFlow-5.14.1-Source
RUN mkdir $ECF_HOME && echo "5.14.1 # version" > $ECF_HOME/ecf.lists  && echo "$ECFLOW_USER" >> $ECF_HOME/ecf.lists
