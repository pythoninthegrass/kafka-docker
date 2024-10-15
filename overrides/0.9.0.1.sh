#!/usr/bin/env bash

set -e

cat << 'DESCRIPTION' >/dev/null
Kafka 0.9.x.x has a 'listeners' config by default. We need to remove this as the user may be configuring via the host.name /
advertised.host.name properties
DESCRIPTION

echo "Removing 'listeners' from server.properties pre-bootstrap"
sed -i -e '/^listeners=/d' "$KAFKA_HOME/config/server.properties"
