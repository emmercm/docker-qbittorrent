#!/usr/bin/env sh
set -euo pipefail

PING_IP=${PING_IP:-1.1.1.1}
IP_URL=${IP_URL:-http://whatismyip.akamai.com}


# Wait for internet connection
# Note: can't use `ping` due to a known issue (https://forums.docker.com/t/ping-from-within-a-container-does-not-actually-ping/11787)
echo "Waiting for internet connection ..."
while ! curl --silent --output /dev/null --max-time 1 ${PING_IP}; do
    sleep 1s
done

# Print external IP
EXTERNAL_IP=$(curl --max-time 10 --silent "${IP_URL}")
echo
echo "*****************$(printf "%${#EXTERNAL_IP}s\n" | tr " " "*")****"
echo "*                $(printf "%${#EXTERNAL_IP}s\n" | tr " " " ")   *"
echo "*   External IP: ${EXTERNAL_IP}   *"
echo "*                $(printf "%${#EXTERNAL_IP}s\n" | tr " " " ")   *"
echo "*****************$(printf "%${#EXTERNAL_IP}s\n" | tr " " "*")****"
echo


# Default qBittorrent config
if [[ ! -f /config/qBittorrent.conf ]]; then
    cp /default/qBittorrent.conf /config/qBittorrent.conf.default
fi

qbittorrent-nox
