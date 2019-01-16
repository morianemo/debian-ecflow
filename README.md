# debian-ecflow
ecflow ecflowview ecflow_ui

https://software.ecmwf.int/wiki/display/ECFLOW/Documentation

jupyter notebook --ip=127.0.0.1 ecFlow.ipynb

docker pull jupyter/datascience-notebook
https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html
docker run -p 8888:8888 jupyter/scipy-notebook:2c80cf3537ca
docker run --rm -p 10000:8888 -e JUPYTER_LAB_ENABLE=yes -v "$PWD":/home/jovyan/work jupyter/datascience-notebook:e5c5a7d3e52d

firefox http://localhost:10000/tree