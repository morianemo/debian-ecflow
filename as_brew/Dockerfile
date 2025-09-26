# Image de base Ubuntu ARM64
FROM --platform=linux/arm64 ubuntu:22.04

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    build-essential curl file git \
    procps

# Installer Homebrew (Linux ARM64)
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ajouter Homebrew au PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/Homebrew/bin:${PATH}"

# Vérifier l'installation
RUN brew --version
# RUN brew install ecflow-ui
RUN brew install --build-from-source qt6
RUN brew install --build-from-source ecflow-ui
RUN ecflow_client --version

