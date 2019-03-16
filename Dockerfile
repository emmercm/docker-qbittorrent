ARG ARCHITECTURE=library
ARG ALPINE_VERSION=latest

FROM ${ARCHITECTURE}/alpine:${ALPINE_VERSION} AS qbittorrent-nox

ARG LIBTORRENT_VERSION=.
ARG QBITTORRENT_VERSION=.

# Build libtorrent-rasterbar[-dev]
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk add --no-cache                       boost-system g++ gcc musl openssl && \
    apk add --no-cache --virtual .build-deps autoconf automake boost-dev file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${LIBTORRENT_VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    # https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
    # https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption --with-libgeoip=system CXXFLAGS=-std=c++11 && \
    make clean && \
    make -j$(nproc) && \
    make uninstall && \
    make install-strip && \
    # Remove intermediary files
    cd && \
    apk del --purge .build-deps && \
    rm -rf /tmp/*

# Build qbittorrent-nox
RUN set -euo pipefail && \
    # Install both executable dependencies and build dependencies
    cd $(mktemp -d) && \
    apk add --no-cache                       boost-system g++ gcc glib icu-libs libintl libpcre2-16 openssl qt5-qtbase zlib && \
    apk add --no-cache --virtual .build-deps boost-dev g++ gcc git make pkgconfig qt5-qttools-dev && \
    # Checkout from source
    git clone https://github.com/qbittorrent/qBittorrent.git && \
    cd qBittorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${QBITTORRENT_VERSION}" | head -1) && \
    # Configure and make
    # https://github.com/qbittorrent/qBittorrent/wiki/Running-qBittorrent-without-X-server#compile-from-source---how-to-disable-qbittorrents-gui
    ./configure --disable-gui && \
    make -j$(nproc) && \
    make install && \
    # Remove intermediary files
    cd && \
    apk del --purge .build-deps && \
    rm -rf /tmp/* && \
    # Test executable works
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
