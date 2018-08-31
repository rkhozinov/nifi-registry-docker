# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

FROM openjdk:8-jdk-slim
LABEL maintainer="Ruslan Khozinov <ruslan.khozinov@gmail.com>"

ARG UID=1000
ARG GID=1000
ARG NIFI_REGISTRY_VERSION=0.2.0
ARG NIFI_TOOLKIT_VERSION=1.6.0
ARG MIRROR=https://archive.apache.org/dist

ENV DEBIAN_FRONTEND=noninteractive
ENV NIFI_REGISTRY_BASE_DIR /opt/nifi-registry
ENV NIFI_TOOLKIT_BASE_DIR /opt/nifi-toolkit
ENV NIFI_REGISTRY_HOME=${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} \
    NIFI_REGISTRY_BINARY_URL=nifi/nifi-registry/nifi-registry-${NIFI_REGISTRY_VERSION}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz

ENV NIFI_TOOLKIT_HOME=${NIFI_TOOLKIT_BASE_DIR}/nifi-toolkit-${NIFI_TOOLKIT_VERSION} \
    NIFI_TOOLKIT_BINARY_URL=${NIFI_TOOLKIT_BINARY_URL:-/nifi/${NIFI_TOOLKIT_VERSION}/nifi-toolkit-${NIFI_TOOLKIT_VERSION}-bin.tar.gz}

ADD sh/ ${NIFI_REGISTRY_BASE_DIR}/scripts/

# Setup NiFi-Registry user
RUN groupadd -g ${GID} nifi || groupmod -n nifi `getent group ${GID} | cut -d: -f1` \
    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m nifi \
    && mkdir -p ${NIFI_REGISTRY_BASE_DIR} ${NIFI_TOOLKIT_BASE_DIR} \
    && chown -R nifi:nifi ${NIFI_REGISTRY_BASE_DIR} ${NIFI_TOOLKIT_BASE_DIR} \
    && apt-get update -q -y \
    && apt-get install -q -y curl jq xmlstarlet

USER nifi

# Download, validate, and expand Apache NiFi-Registry binary.
RUN curl -fSL ${MIRROR}/${NIFI_REGISTRY_BINARY_URL} -o /tmp/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && echo "$(curl ${MIRROR}/${NIFI_REGISTRY_BINARY_URL}.sha256) */tmp/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz -C ${NIFI_REGISTRY_BASE_DIR} \
    && rm /tmp/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && chown -R nifi:nifi ${NIFI_REGISTRY_HOME}

# Download, validate, and expand Apache NiFi Toolkit binary.
RUN curl -fSL ${MIRROR}/${NIFI_TOOLKIT_BINARY_URL} -o /tmp/nifi-toolkit-${NIFI_TOOLKIT_VERSION}-bin.tar.gz  \
    && echo "$(curl ${MIRROR}/${NIFI_TOOLKIT_BINARY_URL}.sha256) */tmp/nifi-toolkit-${NIFI_TOOLKIT_VERSION}-bin.tar.gz" | sha256sum -c -  \
    && tar -xzf /tmp/nifi-toolkit-${NIFI_TOOLKIT_VERSION}-bin.tar.gz -C ${NIFI_TOOLKIT_BASE_DIR} \
    && rm /tmp/nifi-toolkit-${NIFI_TOOLKIT_VERSION}-bin.tar.gz \
    && chown -R nifi:nifi ${NIFI_TOOLKIT_HOME}

# Web HTTP(s) ports
EXPOSE 18080 18443

WORKDIR ${NIFI_REGISTRY_HOME}

# Apply configuration and start NiFi Registry
CMD ${NIFI_REGISTRY_BASE_DIR}/scripts/start.sh
