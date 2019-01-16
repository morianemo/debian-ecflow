# debian-ecflow
ecflow ecflowview ecflow_ui
https://software.ecmwf.int/wiki/display/ECFLOW/Documentation

docker build -t ecflow .

jupyter notebook --ip=127.0.0.1 ecFlow.ipynb
docker build --rm --tag ${USER}/ecflow:base \
  -f docker/base/Dockerfile .
docker build --rm --tag ${USER}/ecflow:python \
  -f docker/python/Dockerfile .
docker build --rm --tag ${USER}/ecflow:server \
  -f docker/server/Dockerfile .
docker run -d -p ${local_port:=3141}:2500 \
  --name this-ecflow-server ${USER}/ecflow:server

HTTP=https://software.ecmwf.int/wiki/download/attachments/8650755	
TE=ecFlow-4.12.0-Source.tar.gz
wget --output-document=${TE} ${HTTP}/${TE}?api=v2

TB=boost_1_53_0.tar.gz 
wget --output-document=${TB} ${HTTP}/${TB}?api=v2

map

git clone https://map@git.ecmwf.int/scm/ecflow/ecflow.git
cd ecflow; git checkout develop; cd ../
ver=ecFlow-4.12.0-Source; mv ecflow $ver
tar -cvf ${ver}.tar $ver && gzip ${ver}.tar
wget https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
cd $HOME; tar -czvf cmake.tgz cmake bin/ecbuild*

touch ${ver}.tar.gz
##################################################################
for file in /opt/java/current/bin/*
do
   if [ -x $file ]
   then
      filename=`basename $file`
      sudo update-alternatives --install /usr/bin/$filename $filename $file 20000
      sudo update-alternatives --set $filename $file
      #echo $file $filename
   fi
done

https://colab.research.google.com/notebooks/welcome.ipynb



/usr/local/bin/

/usr/local/lib/python3.5/site-packages/ecflow

-- Installing: /usr/local/share/ecflow/cmake/ecflow-config-version.cmake
-- Installing: /usr/local/share/ecflow/cmake/ecflow-config.cmake
-- Installing: /usr/local/share/ecflow/cmake/ecflow-targets.cmake
-- Installing: /usr/local/share/ecflow/cmake/ecflow-targets-release.cmake
-- Installing: /usr/local/bin/ecflow_client
-- Up-to-date: /usr/local/bin/ecflow_client
-- Installing: /usr/local/bin/ecflow_standalone
-- Installing: /usr/local/bin/ecflow_fuse.py
-- Installing: /usr/local/bin/ecflow_logsvr.pl
-- Installing: /usr/local/bin/noconnect.sh
-- Installing: /usr/local/bin/ecflow_start.sh
-- Installing: /usr/local/bin/ecflow_stop.sh
-- Installing: /usr/local/bin/ecflow_logserver.sh
-- Installing: /usr/local/bin/ecflow_server
-- Up-to-date: /usr/local/bin/ecflow_server

FROM debian:stretch
# FROM debian:jessie

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

WORKDIR /tmp

# variables used for compilation, they can be removed after the built
ENV WK=/tmp/ecflow_build/ecFlow-4.12.0-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_53_0 \
    HTTP=https://software.ecmwf.int/wiki/download/attachments/8650755 \ 
    TE=ecFlow-4.12.0-Source.tar.gz \
    TB=boost_1_53_0.tar.gz \
    COMPILE=1

# echo 'file=${WK}/view/src/libxec/xec_Regexp.c; add="#define NO_REGEXP"; sed -i $file -e "s:regexp.h:regex.h:"; sed -i "1i $add" "$file"' > fix_regex.sh

COPY fix_regex.sh /tmp/

RUN mkdir -p ${WK}/build

RUN rm -rf /tmp/ecflow_build
RUN mkdir -p /tmp/ecflow_build

# development
COPY ecFlow-4.12.0-Source.tar.gz /tmp/ecflow_build/
COPY boost_1_53_0.tar.gz /tmp/ecflow_build/

# network
# RUN cd /tmp/ecflow_build && wget --output-document=${TE} ${HTTP}/${TE}?api=v2 && wget --output-document=${TB} ${HTTP}/${TB}?api=v2 \
RUN cd /tmp/ecflow_build \    
    && tar -xzvf ${TE} \
    && tar -xzvf ${TB} 

RUN apt-get install -y apt-utils python3-dev

RUN test ${COMPILE} -eq 1 && /tmp/fix_regex.sh \
    && cd ${BOOST_ROOT} && ./bootstrap.sh \
    && python_root=$(python3 -c "import sys; print(sys.prefix)") \
    && ./bootstrap.sh  --with-python-root=$python_root \
                       --with-python=/usr/bin/python3 \
    && sed -i "s|using python : 3.5 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
    && ln -sf /usr/include/python3.5m /usr/include/python \
    && ln -sf /usr/include/python3.5m /usr/include/python3.5 \
    && $WK/build_scripts/boost_1_53_fix.sh

# RUN apt-get install -y bjam # libboost1.62-tools-dev
# RUN cd /tmp/ecflow_build/boost_1_53_0 && test ! -x ./bjam && cp /usr/bin/bjam .
# COPY bjam /tmp/ecflow_build/boost_1_53_0/
RUN cd ${BOOST_ROOT} && bash ${WK}/build_scripts/boost_build.sh

COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/
RUN cd /tmp/ecflow_build/ \
    && tar -xzf cmake-3.13.2.tar.gz \
    && cd cmake-3.13.2 \
    && ./configure \
    && make && make install

COPY cmake.tgz /tmp/ecflow_build/

RUN cd $HOME && tar -xzf /tmp/ecflow_build/cmake.tgz
RUN find $HOME/.

#######################

FROM ubuntu:14.04

RUN apt-get update && apt-get install -y firefox

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer
CMD /usr/bin/firefox

docker build -t firefox . it and run the container with:

docker run -ti --rm \
       -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       firefox
       
docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
       ecflowview

docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
       ecflow_ui


       /tmp/ecflow_build/boost_1_53_0/boost/get_pointer.hpp:27:40: warning: 'template<class> class std::auto_ptr' is deprecated [-Wdeprecated-declarations]

https://map@git.ecmwf.int/scm/em/suites.git

https://github.com/yui/yui3/wiki/Set-Up-Your-Git-Environment

docker run -p 5900 -e HOME=/ creack/firefox-vnc x11vnc -forever -usepw -create

docker run -p 5900 creack/firefox-vnc x11vnc -forever -usepw -create

# Firefox over VNC
#
# VERSION               0.1
# DOCKER-VERSION        0.2

FROM    ubuntu:12.04
# Make sure the package repository is up to date
RUN     echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN     apt-get update

# Install vnc, xvfb in order to create a 'fake' display and firefox
RUN     apt-get install -y x11vnc xvfb firefox
RUN     mkdir ~/.vnc
# Setup a password
RUN     x11vnc -storepasswd 1234 ~/.vnc/passwd
# Autostart firefox (might not be the best way to do it, but it does the trick)
RUN     bash -c 'echo "firefox" >> /.bashrc'

docker build -t xeyes - << __EOF__
FROM debian
RUN apt-get update
RUN apt-get install -qqy x11-apps
ENV DISPLAY 192.168.1.76:0
CMD xeyes
__EOF__
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix   -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH xeyes xeyes

ecflow /usr/local/bin/ecflowview
--env="QT_X11_NO_MITSHM=1"

#####################

#!/usr/bin/env bash

CONTAINER=py3:2016-03-23-rc3
COMMAND=/bin/bash
NIC=en0

# Grab the ip address of this box
IPADDR=$(ifconfig $NIC | grep "inet " | awk '{print $2}')

DISP_NUM=$(jot -r 1 100 200)  # random display number between 100 and 200

PORT_NUM=$((6000 + DISP_NUM)) # so multiple instances of the container won't interfer with eachother

socat TCP-LISTEN:${PORT_NUM},reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" 2>&1 > /dev/null &

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth.$USER.$$
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

IPADDR=192.168.1.76:
DISP=192.168.1.76:0

docker run \
    -it \
    --rm --privileged \
    -v $XSOCK:$XSOCK:rw \
    -v $XAUTH:$XAUTH:rw \
    -e DISPLAY=$DISP \
    -e XAUTHORITY=$XAUTH xeyes xeyes
    $CONTAINER \
    $COMMAND

    --user=$USER \
    --workdir="/Users/$USER" \
    -v "/Users/$USER:/home/$USER:rw" \

rm -f $XAUTH
kill %1       # kill the socat job launched above

xhost local:root
sudo docker run  --env DISPLAY=unix$DISPLAY --privileged --volume $XAUTH:/root/.Xauthority --volume /tmp/.X11-unix:/tmp/.X11-unix  --rm --runtime=nvidia --rm -it -v /home/alex/coding:/coding  alexcpn/nvidia-cuda-grpc:1.0 bash


docker run \
    -it \
    --rm --privileged \
    -v $XSOCK:$XSOCK:rw \
    -v $XAUTH:$XAUTH:rw \
    -e DISPLAY=$DISP \
    -e XAUTHORITY=$XAUTH xeyes xeyes
docker run \
    -it \
    --rm --privileged \
    -v $XSOCK:$XSOCK:rw \
    -v $XAUTH:$XAUTH:rw \
    -e DISPLAY=$DISP \
    -e XAUTHORITY=$XAUTH xeyes xeyes

docker run -it \
     --env="DISPLAY" \
     --env="QT_X11_NO_MITSHM=1" \
     --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" xeyes xeyes
     export containerId=$(docker ps -l -q)
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $containerId`
docker start $containerId

docker run -it \
    --env="DISPLAY" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" xeyes xeyes

docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix   -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH xeyes


export DISPLAY=$WINDOWS_MACHINE_IP_ADD:0

export DISPLAY=172.16.61.1:0
# export DISPLAY=192.168.45.1:0
docker run -ti --rm -e DISPLAY=$DISPLAY xeyes
<hostname>:<display>.<monitor>


docker run -it ubuntu bash

apt-get update
apt-get install xvfb
Xvfb :1 -screen 0 1024x768x16 &> xvfb.log  &
ps aux | grep X
DISPLAY=:1.0
export DISPLAY
firefox

docker run -e DISPLAY -v $HOME/.Xauthority:$HOME/.Xauthority --net=host -ti xeyes /bin/bash

xhost +
docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ecflow ecflowview
docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ecflow ecflow_ui

https://github.com/mozilla/geckodriver/releases

git config --global credential.helper cache