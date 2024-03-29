FROM debian:buster

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
ENV WK=/tmp/ecflow_build/ecFlow-5.10.0-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_71_0 \
    TE=ecFlow-5.10.0-Source.tar.gz \
    TB=boost_1_71_0.tar.gz \
    COMPILE=0 \
    HTTPB=https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/${TB} \
    HTTP=https://confluence.ecmwf.int/download/attachments/8650755

RUN mkdir -p ${WK}/build
RUN rm -rf /tmp/ecflow_build
RUN mkdir -p /tmp/ecflow_build

ENV CM=https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz
RUN cd /tmp/ecflow_build/ && wget -O  /tmp/ecflow_build/cmake-3.tgz ${CM}

# COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/
RUN cd /tmp/ecflow_build/ \
    && tar -xzf cmake-3.tgz \
    && cd cmake-3.* \
    && ./configure && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

# uncomment following in development mode
# COPY cmake.tgz /tmp/ecflow_build/

# development
# COPY ecFlow-5.10.0-Source.tar.gz /tmp/ecflow_build/
# COPY boost_1_71_0.tar.gz /tmp/ecflow_build/

# network: uncomment following line
#RUN cd /tmp/ecflow_build && wget --output-document=${TE} ${HTTP}/${TE}?api=v2 \
#    && tar -xzvf ${TE} \
RUN cd /tmp/ecflow_build && wget --output-document=${TB} ${HTTPB}/${TB}?api=v2 \
    && tar -xzvf ${TB} 

RUN ln -sf /usr/lib/x86_64-linux-gnu /usr/lib64

RUN apt-get install -y libssl1.1

RUN cd ${BOOST_ROOT} && ./bootstrap.sh \
  && python_root=$(python3 -c "import sys; print(sys.prefix)") \
  && ./bootstrap.sh --with-python-root=$python_root --with-python=/usr/bin/python3
#  && sed -i "s|using python : 3.7 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
#  && sed -i -e 's/1690/1710/' ${WK}/build_scripts/boost_build.sh   
#  && ln -sf /usr/include/python3.7 /usr/include/python 
#  && ln -sf /usr/include/python3.7m /usr/include/python3.7 

# RUN cd ${BOOST_ROOT} && bash ${WK}/build_scripts/boost_build.sh

RUN apt-get -y update --fix-missing
RUN apt-get -y install --fix-missing apt-utils qtscript5-dev libssl-dev unzip
ENV PATH=/root/bin:$PATH CMAKE_MODULE_PATH=/root/cmake:/root 

RUN apt-get -y install libqt5widgets5 libqt5network5 libqt5gui5 libqt5svg5-dev libqt5charts5-dev doxygen

RUN cd  ${DBUILD} && wget -O ecbuild.zip \
  https://github.com/ecmwf/ecbuild/archive/refs/heads/develop.zip && \
  unzip ecbuild.zip && \
  cd ecbuild-* && mkdir build && cd build && cmake ../ && make && make install

RUN export ETGZ=ecFlow.zip HTTPE=https://confluence.ecmwf.int/download/attachments/8650755 \
    && cd ${DBUILD} && wget -O ${ETGZ} \
      https://github.com/ecmwf/ecflow/archive/refs/heads/develop.zip \
    && unzip ${ETGZ}
    
RUN ln -sf ${DBUILD}/ecflow-develop ${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source

RUN mkdir -p ${WK}/build && cd ${WK}/build \
  && cmake .. -DCMAKE_MODULE_PATH=/root/cmake -DENABLE_UI=ON \
  && make -j$(grep processor /proc/cpuinfo | wc -l) && make install # && make test && cd /tmp

# RUN mkdir -p ${WK}/build && cd ${WK}/build && cmake .. -DCMAKE_MODULE_PATH=/root/cmake -DENABLE_UI=OFF

RUN cd ${WK}/build && make -j$(grep processor /proc/cpuinfo | wc -l) && make install # && make test && cd /tmp
# RUN cd ${WK}/build && cmake .. -DCMAKE_MODULE_PATH=/root/cmake && make && make install && make test && cd /tmp && rm -rf *

# environment variables for ecFlow server
ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
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

RUN mkdir $ECF_HOME && echo "5.10.0 # version" > $ECF_HOME/ecf.lists  && echo "$ECFLOW_USER" >> $ECF_HOME/ecf.lists
