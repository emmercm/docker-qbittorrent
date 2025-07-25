# Instructions on building qBittorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Compiling_qBittorrent_without_the_GUI_aka_qBittorrentnox_aka_headless
#   https://github.com/qbittorrent/qBittorrent/wiki/Running-qBittorrent-without-X-server#compile-from-source---how-to-disable-qbittorrents-gui
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

FROM emmercm/libtorrent:1.2@sha256:d5eb45e812c39c15bc433be047746a832559e840bb1bdb8f7d362708a9e8b6f6

ARG VERSION=4.3.[0-9]*

COPY entrypoint.sh qBittorrent.conf /

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build qbittorrent-nox
# hadolint ignore=DL3003,DL3018
RUN apk --update add --no-cache                              qt5-qtbase && \
    apk --update add --no-cache --virtual build-dependencies boost-dev g++ gcc git make pkgconfig qt5-qttools-dev && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone https://github.com/qbittorrent/qBittorrent.git && \
    cd qBittorrent && \
    git checkout "$(git tag --sort=-version:refname | grep '\.[0-9]\+$' | grep "${VERSION}" | head -1)" && \
    # Configure and make
    ./configure --disable-gui && \
    make "-j$(nproc)" && \
    make install && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    qbittorrent-nox -v && \
    # Make directories, and symlink them for quality of life
    mkdir -p ~/.config/qBittorrent && \
    mkdir -p ~/.local/share/qBittorrent && \
    mkdir /downloads && \
    mkdir /incomplete && \
    ln -s ~/.config/qBittorrent /config && \
    ln -s ~/.local/share/qBittorrent /data && \
    # Install container and entrypoint dependencies
    apk --update add --no-cache curl dumb-init tzdata

VOLUME ["/config", "/data", "/downloads", "/incomplete"]

EXPOSE 8080 6881/tcp 6881/udp

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["qbittorrent-nox"]
