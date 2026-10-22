#!/usr/bin/env sh
set -euo pipefail

PING_IPS=${PING_IPS:-1.1.1.1 1.0.0.1}
IP_URL=${IP_URL:-http://whatismyip.akamai.com}


# Wait for internet connection
# Note: can't use `ping` due to a known issue (https://forums.docker.com/t/ping-from-within-a-container-does-not-actually-ping/11787)
echo "Waiting for internet connection ..."
while true; do
    for PING_IP in ${PING_IPS}; do
        if curl --silent --output /dev/null --max-time 1 ${PING_IP}; then
            break 2
        fi
    done
    sleep 1
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
    cp /qBittorrent.conf /config/qBittorrent.conf
fi

exec "$@"
