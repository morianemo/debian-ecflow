# debian-ecflow
ecflow ecflowview ecflow_ui
https://software.ecmwf.int/wiki/display/ECFLOW/Documentation

img=ecflow-debian 
docker build -t $img .

docker run --net=host -ti $img bash
docker run --net=host -ti $img ecflow_client --help
docker run --net=host -ti $img ecflow_server --port 2500

xhost +
gui=ecflow_ui
# gui=ecflowview
docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti $img $gui

jupyter notebook --ip=127.0.0.1 ecFlow.ipynb
export LANG=C

make client.x
ECF_PORT=2500 ./client.x
https://mybinder.org/v2/gh/morianemo/debian-ecflow/master?filepath=notebook%2FecFlow.ipynb
https://mybinder.org/v2/gh/morianemo/debian-ecflow/master
