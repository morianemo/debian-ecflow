FROM condaforge/miniforge3

# COPY environment.yml /tmp/environment.yml
RUN conda install ecflow -c conda-forge
RUN apt-get update && \
    apt-get install -y msmtp mailutils vim
RUN apt-get install -y libxcb-xinerama0 libx11-xcb1    
# RUN rm -rf /var/lib/apt/lists/*
RUN apt-get install -y sudo

ENV ECFLOW_USER=ecflow \
    ECF_PORT=3141 \
    ECF_HOME=/home/ecflow/ecflow_server \
    HOME=/home/ecflow \
    HOST=ecflow \
    USER=ecflow \  
    LANG=en_US.UTF-8\
    TZ=UTC
ENV ECFLOW_BINDIR=/opt/conda/bin     
RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ${ECFLOW_USER} /home/${ECFLOW_USER} && chgrp ${ECFLOW_USER} /home/${ECFLOW_USER}
# RUN adduser ${ECFLOW_USER} sudo    
# USER ecflow
COPY starter.sh /tmp/starter.sh
COPY ./ecflow_start_nohup.sh /opt/conda/bin/ecflow_start_nohup.sh
EXPOSE ${ECF_PORT}RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --system --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ecflow /home/ecflow && chgrp ecflow /home/ecflow
USER ecflow
WORKDIR /home/ecflow
ENV DISPLAY=:0
RUN mkdir $ECF_HOME && echo "5.15.1 # version" > $ECF_HOME/ecf.lists  && echo "$ECFLOW_USER" >> $ECF_HOME/ecf.lists
# RUN conda env create -f /tmp/environment.yml && conda clean -afy
# SHELL ["conda", "run", "-n", "menv", "/bin/bash", "-c"]
# CMD ["python"]

