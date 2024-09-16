ARG CI_REGISTRY_IMAGE
ARG TAG
ARG APP_NAME
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="paoloemilio.mazzon@unipd.it"


ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG TAG
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION
ARG APP_VERSION_FULL="${APP_VERSION}-20240422"

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        libfontconfig1 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxkbcommon-x11-0 \
        libxkbcommon0 && \
        cd /var/cache/ && \
        curl -sSL -o itksnap-${APP_VERSION_FULL}.tgz https://sourceforge.net/projects/itk-snap/files/itk-snap/${APP_VERSION}/itksnap-${APP_VERSION_FULL}-Linux-gcc64.tar.gz/download && \
        tar -xvzf itksnap-${APP_VERSION_FULL}.tgz && \
        mv itksnap-${APP_VERSION_FULL}-Linux-gcc64/* /apps/${APP_NAME} && \
        rmdir itksnap-${APP_VERSION_FULL}-Linux-gcc64 && cd / && apt-get -y --purge autoremove

ARG TAG
ARG CARD
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG
ENV PATH=$PATH:/apps/${APP_NAME}/bin

WORKDIR /apps/${APP_NAME}

ENV APP_SPECIAL=""
ENV APP_CMD="/apps/${APP_NAME}/bin/itksnap"
ENV PROCESS_NAME="itksnap"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
