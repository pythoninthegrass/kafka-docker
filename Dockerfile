# syntax=docker/dockerfile:1.7.0

FROM openjdk:11-jre-slim

ARG kafka_version=2.8.1
ARG scala_version=2.13
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="kafka"
LABEL org.label-schema.description="Apache Kafka"
LABEL org.label-schema.build-date="${build_date}"
LABEL org.label-schema.vcs-url="https://github.com/pythoninthegrass/kafka-docker"
LABEL org.label-schema.vcs-ref="${vcs_ref}"
LABEL org.label-schema.version="${scala_version}_${kafka_version}"
LABEL org.label-schema.schema-version="1.0"
LABEL maintainer="pythoninthegrass"

ENV KAFKA_VERSION=$kafka_version
ENV SCALA_VERSION=$scala_version
ENV KAFKA_HOME=/opt/kafka
ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp2/

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-eux", "-o", "pipefail", "-c" ]

RUN <<EOF
#!/usr/bin/env bash
apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends jq net-tools curl wget

### BEGIN docker for CI tests
apt-get install -y --no-install-recommends gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y --no-install-recommends docker-ce-cli
apt-get remove -y gnupg lsb-release
apt-get clean
apt-get autoremove -y
apt-get -f install
### END docker for CI tests

### BEGIN other for CI tests
apt-get install -y --no-install-recommends netcat
### END other for CI tests

chmod a+x /tmp2/*.sh
mv /tmp2/start-kafka.sh /tmp2/broker-list.sh /tmp2/create-topics.sh /tmp2/versions.sh /usr/bin
sync
/tmp2/download-kafka.sh
tar xfz /tmp2/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt
rm /tmp2/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME}
rm -rf /tmp2
rm -rf /var/lib/apt/lists/*
EOF

COPY overrides /opt/overrides

VOLUME ["/kafka"]

CMD ["start-kafka.sh"]

LABEL org.opencontainers.image.title="kafka"
