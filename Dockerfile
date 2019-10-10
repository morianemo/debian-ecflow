FROM debian:bullseye

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8 \
  && apt-get install -y build-essential cmake python-dev python3-dev qtbase5-dev \
    libmotif-dev libx11-dev libxext-dev libxpm-dev vim fvwm libxt-dev \
    xvfb wget \
  && apt-get install -qqy x11-apps

WORKDIR /tmp

# variables used for compilation, they can be removed after the built
ENV WK=/tmp/ecflow_build/ecFlow-5.1.0-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_71_0 \
    TE=ecFlow-5.1.0-Source.tar.gz \
    TB=boost_1_71_0.tar.gz \
    COMPILE=1 \
    HTTPB=https://dl.bintray.com/boostorg/release/1.71.0/source \
    HTTP=https://software.ecmwf.int/wiki/download/attachments/8650755

RUN mkdir -p ${WK}/build
RUN rm -rf /tmp/ecflow_build
RUN mkdir -p /tmp/ecflow_build

# development
# COPY ecFlow-5.1.0-Source.tar.gz /tmp/ecflow_build/
# COPY boost_1_71_0.tar.gz /tmp/ecflow_build/

# network: uncomment following line
RUN cd /tmp/ecflow_build && wget --output-document=${TE} ${HTTP}/${TE}?api=v2 && wget --output-document=${TB} ${HTTPB}/${TB}?api=v2 
RUN cd /tmp/ecflow_build \    
    && tar -xzvf ${TE} \
    && tar -xzvf ${TB} 

RUN apt-get install -y apt-utils python3-dev

RUN test ${COMPILE} -eq 1 \
    && cd ${BOOST_ROOT} && ./bootstrap.sh \
    && python_root=$(python3 -c "import sys; print(sys.prefix)") \
    && ./bootstrap.sh  --with-python-root=$python_root \
                       --with-python=/usr/bin/python3 \
    && sed -i "s|using python : 3.7 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
    && ln -sf /usr/include/python3.7m /usr/include/python \
    && ln -sf /usr/include/python3.7m /usr/include/python3.7 \
    && sed -i -e 's/1690/1710/' ${WK}/build_scripts/boost_build.sh \
    && ${WK}/build_scripts/boost_build.sh

RUN apt-get -y install git build-essential cmake qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools qtmultimedia5-dev libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev

# RUN apt-get install -y bjam # libboost1.62-tools-dev
# RUN cd /tmp/ecflow_build/boost_1_53_0 && test ! -x ./bjam && cp /usr/bin/bjam .
# COPY bjam /tmp/ecflow_build/boost_1_53_0/
RUN cd ${BOOST_ROOT} && bash ${WK}/build_scripts/boost_build.sh
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz
RUN cd /tmp/ecflow_build/ && wget -O  /tmp/ecflow_build/cmake-3.tgz ${CM}

# COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/
RUN cd /tmp/ecflow_build/ \
    && tar -xzf cmake-3.tgz \
    && cd cmake-3.* \
    && ./configure && make && make install

# uncomment following in development mode
# COPY cmake.tgz /tmp/ecflow_build/

# DEV
# RUN cd $HOME && tar -xzf /tmp/ecflow_build/cmake.tgz
RUN find $HOME/.
ENV PATH=/root/bin:$PATH CMAKE_MODULE_PATH=/root/cmake:/root 
RUN mkdir -p ${WK}/build \
    && cd ${WK}/build \
    && cmake .. -DCMAKE_MODULE_PATH=/root/cmake -DENABLE_GUI=ON -DENABLE_UI=OFF \
    && make -j2 && make install # && make test && cd /tmp

RUN apt-get -y install git build-essential cmake qt5-default qtscript5-dev \
    libssl-dev qttools5-dev qttools5-dev-tools qtmultimedia5-dev libqt5svg5-dev \
    libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev \
    libasound2-dev libjack-jackd2-dev libxrandr-dev
# libqt5xmlpatterns5 libqt5xmlpatterns5-private-dev
RUN cd ${WK}/build \
  && cmake .. -DCMAKE_MODULE_PATH=/root/cmake \
  && make && make install
# && make test && cd /tmp && rm -rf *

# environment variables for ecFlow server
ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=en_US.UTF-8 \
    PYTHONPATH=/usr/local/lib/python3.7/site-packages

EXPOSE ${ECF_PORT}

RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ecflow /home/ecflow && chgrp ecflow /home/ecflow

USER ecflow
WORKDIR /home/ecflow
ENV DISPLAY=:0

