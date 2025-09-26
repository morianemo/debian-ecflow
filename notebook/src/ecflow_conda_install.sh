#!/usr/bin/env bash
# conda init bash
# conda create -n $name
# conda activate $name
conda install ecflow -c conda-forge
python3 -c 'import ecflow; help(ecflow.ecflow)'
