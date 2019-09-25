[![](https://raw.githubusercontent.com/emmercm/docker-qbittorrent/assets/qbittorrent.png)](https://www.qbittorrent.org/)

[![](https://badgen.net/badge/emmercm/qbittorrent/blue?icon=docker)](https://hub.docker.com/r/emmercm/qbittorrent)
[![](https://badgen.net/docker/pulls/emmercm/qbittorrent?icon=docker)](https://hub.docker.com/r/emmercm/qbittorrent)

[![](https://badgen.net/badge/emmercm/docker-qbittorrent/purple?icon=github)](https://github.com/emmercm/docker-qbittorrent)
[![](https://badgen.net/circleci/github/emmercm/docker-qbittorrent/master?icon=circleci)](https://github.com/emmercm/docker-qbittorrent/blob/master/.circleci/config.yml)
[![](https://badgen.net/github/license/emmercm/docker-qbittorrent?color=grey)](https://github.com/emmercm/docker-qbittorrent/blob/master/LICENSE)

Headless qBittorrent client with remote web interface.

# Supported tags

| Tags | Size / Layers |
|-|-|
| `4.1.7`, `4.1.7-alpine`, `4.1`, `4.1-alpine`, `4`, `4-alpine`, `latest` | [![](https://images.microbadger.com/badges/image/emmercm/qbittorrent:4.1.7.svg)](https://microbadger.com/images/emmercm/qbittorrent:4.1.7 "Get your own image badge on microbadger.com") |
| `4.0.4`, `4.0.4-alpine`, `4.0`, `4.0-alpine` | [![](https://images.microbadger.com/badges/image/emmercm/qbittorrent:4.0.4.svg)](https://microbadger.com/images/emmercm/qbittorrent:4.0.4 "Get your own image badge on microbadger.com") |
| `3.3.16`, `3.3.16-alpine`, `3.3`, `3.3-alpine`, `3`, `3-alpine` | [![](https://images.microbadger.com/badges/image/emmercm/qbittorrent:3.3.16.svg)](https://microbadger.com/images/emmercm/qbittorrent:3.3.16 "Get your own image badge on microbadger.com") |

# What is qBittorrent?

From [www.qbittorrent.org](https://www.qbittorrent.org/):

> _An advanced and multi-platform BitTorrent client with a nice Qt user interface as well as a Web UI for remote control and an integrated search engine. qBittorrent aims to meet the needs of most users while using as little CPU and memory as possible._
>
> _The qBittorrent project aims to provide an open-source software alternative to µTorrent._

qBittorrent is released uner the [GNU Generic Public License v2](https://github.com/qbittorrent/qBittorrent/blob/master/COPYING) to allow free use.

# How to use these images

These images are built with `qbittorrent-nox` (no X server), a version of qBittorrent with the GUI disabled that is controlled via its built-in web UI.

The images do not require any external Docker networks, volumes, environment variables, or arguments and can be run with just:

```bash
docker run \
    --publish 8080:8080 \
    --publish 6881:6881/tcp \
    --publish 6881:6881/udp \
    emmercm/qbittorrent
```

And accessed through the web UI at [http://localhost:8080](http://localhost:8080) with the [default](https://github.com/qbittorrent/qBittorrent/wiki/Web-UI-password-locked-on-qBittorrent-NO-X-%28qbittorrent-nox%29) username `admin` and password `adminadmin`.

## Volume mounts

Due to the ephemeral nature of Docker containers these images provide a number of optional volume mounts to persist data outside of the container:

- `/config`: the qBittorrent config directory containing `qBittorrent.conf`
- `/downloads`: the default download location
- `/incomplete`: the default incomplete download location
- `/data`: the qBittorrent folder that contains fast resume data, `.torrent` files, logs, and other data.

Usage:

```bash
mkdir config downloads incomplete
docker run \
    --publish 8080:8080 \
    --publish 6881:6881/tcp \
    --publish 6881:6881/udp \
    --volume "$PWD/config:/config" \
    --volume "$PWD/data:/data" \
    --volume "$PWD/downloads:/downloads" \
    --volume "$PWD/incomplete:/incomplete" \
    emmercm/qbittorrent
```

## Environment variables

To change the timezone of the container set the `TZ` environment variable. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

## Docker Compose

[`docker-compose`](https://docs.docker.com/compose/) can help with defining the `docker run` config in a repeatable way rather than ensuring you always pass the same CLI arguments.

Here's an example `docker-compose.yml` config:

```yaml
version: "3"

services:
  qbittorrent:
    build: .
    environment:
      - TZ=America/New_York
    ports:
      - 8080:8080
      - 6881:6881/tcp
      - 6881:6881/udp
    volumes:
      - ./config:/config
      - ./data:/data
      - ./downloads:/downloads
      - ./incomplete:/incomplete
```

## Docker Compose + VPN

There are a number of VPN images such as Julio Gutierrez's [bubuntux/nordvpn](https://hub.docker.com/r/bubuntux/nordvpn) that let you route network traffic from the qBittorrent container through the VPN of your choice.

Here's an example `docker-compose.yml` config:

```yaml
version: "3"

services:
  vpn:
    image: bubuntux/nordvpn:latest
    cap_add:
      - net_admin
    devices:
      - /dev/net/tun
    environment:
      - USER=user@email.com
      - PASS='pas$word'
      - COUNTRY=United_States
      - PROTOCOL=UDP
      - CATEGORY=P2P
      - NETWORK=192.168.1.0/24
      - OPENVPN_OPTS=--pull-filter ignore "ping-restart" --ping-exit 180
      - TZ=America/New_York
    ports:
      - 8080:8080
      - 6881:6881/tcp
      - 6881:6881/udp
    restart: unless-stopped
  
  qbittorrent:
    image: emmercm/qbittorrent:latest
    network_mode: service:vpn
    environment:
      - TZ=America/New_York
    volumes:
      - ./config:/config
      - ./data:/data
      - ./downloads:/downloads
      - ./incomplete:/incomplete
    restart: unless-stopped
```

# Image variants

## `emmercm/qbittorrent:<version>-alpine`

The default image variant, these images are based on [the `alpine` official image](https://hub.docker.com/_/alpine) which is designed to be "small, simple, and secure." This variant is recommended for when final image size is a concern.

# License

This project is under the [GNU Generic Public License v3](https://github.com/emmercm/docker-qbittorrent/blob/master/LICENSE) to allow free use while ensuring it stays open.
