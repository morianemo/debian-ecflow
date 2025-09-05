FROM homebrew/brew
RUN brew install ecflow-ui 
ENV ECFLOW_USER=ecflow \
    ECF_PORT=3141 \
    ECF_HOME=/home/ecflow/ecflow_server \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=en_US.UTF-8\
    TZ=UTC
USER root    
RUN groupadd --system ${ECFLOW_USER} \
    && useradd --create-home --gid ${ECFLOW_USER} ${ECFLOW_USER} \
    && chown ${ECFLOW_USER} /home/${ECFLOW_USER} && chgrp ${ECFLOW_USER} /home/${ECFLOW_USER}
USER ecflow
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
