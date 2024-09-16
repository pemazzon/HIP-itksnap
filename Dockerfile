ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG} AS base
LABEL maintainer="paoloemilio.mazzon@unipd.it"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG TAG
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

ARG ANTS_VERSION=2.5.3
RUN apt-get update && \
    apt-get install --no-install-recommends -y bc unzip wget && \ 
    cd /opt && \
    wget https://github.com/ANTsX/ANTs/releases/download/v${ANTS_VERSION}/ants-${ANTS_VERSION}-ubuntu-22.04-X64-gcc.zip && \
    unzip ants-${ANTS_VERSION}-ubuntu-22.04-X64-gcc.zip && \
    mv ants-${ANTS_VERSION} ants && \
    rm -f ants-${ANTS_VERSION}-ubuntu-22.04-X64-gcc.zip && \
    apt-get purge -y unzip wget && \
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# the below needs to go on the user environment so
# an external .bash_profile is filled with these
# we leave them here as a reference from the ANTs Dockerfile
ARG LD_LIBRARY_PATH
ENV PATH="/opt/ants/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/ants/lib:$LD_LIBRARY_PATH"

LABEL org.opencontainers.image.authors="ANTsX team" \
      org.opencontainers.image.url="https://stnava.github.io/ANTs/" \
      org.opencontainers.image.source="https://github.com/ANTsX/ANTs" \
      org.opencontainers.image.licenses="Apache License 2.0" \
      org.opencontainers.image.title="Advanced Normalization Tools" \
      org.opencontainers.image.description="ANTs is part of the ANTsX ecosystem (https://github.com/ANTsX). \
ANTs Citation: https://pubmed.ncbi.nlm.nih.gov/24879923"

ENV APP_SPECIAL="terminal"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
