FROM debian:jessie

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8 \
  && apt-get install -y build-essential cmake python-dev qtbase5-dev \
    libmotif-dev libx11-dev libxext-dev libxpm-dev vim fvwm libxt-dev \
    xvfb wget \
  && apt-get install -qqy x11-apps

# sudo apt-get install git build-essential cmake qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools qtmultimedia5-dev libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libqt5xmlpatterns5-private-dev

WORKDIR /tmp

# variables used for compilation, they can be removed after the built
ENV WK=/tmp/ecflow_build/ecFlow-4.9.0-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_53_0 \
    HTTP=https://software.ecmwf.int/wiki/download/attachments/8650755 \ 
    TE=ecFlow-4.9.0-Source.tar.gz \
    TB=boost_1_53_0.tar.gz \
    COMPILE=1

# echo 'file=${WK}/view/src/libxec/xec_Regexp.c; add="#define NO_REGEXP"; sed -i $file -e "s:regexp.h:regex.h:"; sed -i "1i $add" "$file"' > fix_regex.sh

COPY fix_regex.sh /tmp/

RUN mkdir -p ${WK}/build \
    && cd /tmp/ecflow_build \
    && wget --output-document=${TE} ${HTTP}/${TE}?api=v2 \
    && wget --output-document=${TB} ${HTTP}/${TB}?api=v2 \
    && tar -zxvf ${TE} \
    && tar -zxvf ${TB} 

RUN test ${COMPILE} -eq 1 && /tmp/fix_regex.sh \
    && cd ${BOOST_ROOT} && ./bootstrap.sh \
    && ${WK}/build_scripts/boost_1_53_fix.sh \
    && ${WK}/build_scripts/boost_build.sh

RUN cd ${WK}/build && cmake .. -DENABLE_GUI=ON -DENABLE_UI=OFF \
    && make -j2 && make install # && make test && cd /tmp && rm -rf *

# environment variables for ecFlow server
ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=en_US.UTF-8 \
    PYTHONPATH=/usr/local/lib/python2.7/site-packages

EXPOSE ${ECF_PORT}

RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ecflow /home/ecflow && chgrp ecflow /home/ecflow

USER ecflow
WORKDIR /home/ecflow
ENV DISPLAY=:0
