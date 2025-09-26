FROM condaforge/miniforge3

# COPY environment.yml /tmp/environment.yml
RUN conda install ecflow -c conda-forge
RUN apt-get update && \
    apt-get install -y msmtp mailutils vim
RUN apt-get install -y libxcb-xinerama0 libx11-xcb1    
    # && rm -rf /var/lib/apt/lists/*

ENV ECFLOW_USER=ecflow \
    ECF_PORT=3141 \
    ECF_HOME=/home/ecflow/ecflow_server \
    HOME=/home/ecflow \
    HOST=ecflow \
    USER=ecflow \
    ECFLOW_DIR=/opt/conda/bin \
    LANG=en_US.UTF-8\
    TZ=UTC
RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ${ECFLOW_USER} /home/${ECFLOW_USER} && chgrp ${ECFLOW_USER} /home/${ECFLOW_USER}
USER ecflow
COPY starter.sh /tmp/starter.sh
# RUN conda env create -f /tmp/environment.yml && conda clean -afy
# SHELL ["conda", "run", "-n", "menv", "/bin/bash", "-c"]
# CMD ["python"]

