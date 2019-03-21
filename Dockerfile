# Instructions on building qBittorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Compiling_qBittorrent_without_the_GUI_aka_qBittorrentnox_aka_headless
#   https://github.com/qbittorrent/qBittorrent/wiki/Running-qBittorrent-without-X-server#compile-from-source---how-to-disable-qbittorrents-gui
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

ARG BASE_IMAGE=emmercm/libtorrent:latest

FROM ${BASE_IMAGE}

ARG VERSION=.

# Build qbittorrent-nox
RUN set -euo pipefail && \
    # Install both executable dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              qt5-qtbase && \
    apk --update add --no-cache --virtual build-dependencies boost-dev g++ gcc git libexecinfo-dev make pkgconfig qt5-qttools-dev && \
    # Checkout from source
    git clone https://github.com/qbittorrent/qBittorrent.git && \
    cd qBittorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Configure and make
    ./configure --disable-gui LIBS="-lexecinfo" && \
    make -j$(nproc) && \
    make install && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    qbittorrent-nox -v

# Setup qbittorrent-nox
RUN set -euo pipefail && \
    # Make directories, and symlink them for quality of life
    mkdir -p ~/.config/qBittorrent && \
    mkdir -p ~/.local/share/data/qBittorrent && \
    mkdir /downloads && \
    mkdir /incomplete && \
    ln -s ~/.config/qBittorrent /config
COPY qBittorrent.conf /config/qBittorrent.conf.default
VOLUME ["/config", "/downloads", "/incomplete"]
EXPOSE 8080 6881/tcp 6881/udp

# Set up entrypoint
RUN apk add --no-cache curl dumb-init
COPY entrypoint.sh /
CMD ["dumb-init", "/entrypoint.sh"]
