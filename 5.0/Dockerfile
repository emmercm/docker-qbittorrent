# Instructions on building qBittorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux
#   https://github.com/qbittorrent/qBittorrent/wiki/Compilation-with-CMake-common-information

FROM emmercm/libtorrent:2.0@sha256:999cb4120aae23aead3f59722f7df2ca82ee8b8b5da7701a54e64dbac25f749c

ARG VERSION=5.0.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build qbittorrent-nox
# hadolint ignore=DL3003,DL3018
RUN apk --update add --no-cache                              qt6-qtbase && \
    apk --update add --no-cache --virtual build-dependencies \
        # https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux
        build-base cmake curl git linux-headers ninja-build ninja-is-really-ninja python3 re2c tar xz \
        build-dependencies icu-dev openssl-dev qt6-qtbase-dev qt6-qttools-dev zlib-dev \
        # Undocumented qBittorrent dependencies
        boost-dev \
        # Other build dependencies
        coreutils jq git && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone --branch "$( \
        wget -qO - "https://api.github.com/repos/qbittorrent/qBittorrent/tags?per_page=100" | jq -r '.[].name' | \
        awk '{print $1" "$1}' | \
        # Get rid of prefixes
        sed 's/^release[^0-9]//i' | \
        sed 's/^v//i' | \
        # Make sure patch version exists
        sed 's/^\([0-9]\+\.[0-9]\+\)\([^0-9.].\+\)/\1.0\2/' | \
        # Get the right version
        sort --version-sort --key=1,1 | \
        grep "^${VERSION}" | \
        tail -1 | \
        awk '{print $2}' \
    )" --depth 1 https://github.com/qbittorrent/qBittorrent.git && \
    cd qBittorrent && \
    # Configure and make
    mkdir build-nox && \
    cd build-nox && \
    cmake \
        # https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux#qbittorrent
        -Wno-dev \
        -G Ninja \
        -D CMAKE_BUILD_TYPE="release" \
        -D CMAKE_CXX_STANDARD=20 \
        -D GUI=OFF \
        # https://github.com/qbittorrent/docker-qbittorrent-nox/blob/c02f8b755e23e648dcbf257a96eb7bd2d67505ba/Dockerfile
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
        # https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/qbittorrent/APKBUILD
        -D CMAKE_INSTALL_PREFIX=/usr \
        -DWEBUI=ON \
        -DSTACKTRACE=OFF \
        -DTESTING=OFF \
        .. && \
    (ninja "-j$(nproc)" || \
        # Ninja sometimes fails with one of:
        #   c++: internal compiler error: Illegal instruction signal terminated program as
        #   c++: internal compiler error: Illegal instruction signal terminated program lto1
        # and other times it only reports:
        #   ninja: build stopped: subcommand failed.
        (sleep 5 && ninja) || \
        (sleep 5 && ninja) || \
        (sleep 5 && ninja) || \
        (sleep 5 && ninja) \
    ) && \
    ninja install && \
    cd .. && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    qbittorrent-nox --version && \
    rm ~/.config/qBittorrent/qBittorrent.conf && \
    # Make directories, and symlink them for quality of life
    mkdir -p ~/.config/qBittorrent && \
    mkdir -p ~/.local/share/qBittorrent && \
    mkdir /downloads && \
    mkdir /incomplete && \
    ln -s ~/.config/qBittorrent /config && \
    ln -s ~/.local/share/qBittorrent /data && \
    # Install container and entrypoint dependencies
    apk --update add --no-cache curl dumb-init tzdata

COPY entrypoint.sh qBittorrent.conf /

VOLUME ["/config", "/data", "/downloads", "/incomplete"]

EXPOSE 8080 6881/tcp 6881/udp

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["qbittorrent-nox"]
