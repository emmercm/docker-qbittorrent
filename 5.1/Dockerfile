# Instructions on building qBittorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux
#   https://github.com/qbittorrent/qBittorrent/wiki/Compilation-with-CMake-common-information

FROM emmercm/libtorrent:2.0@sha256:813289983b76576a0fd65ce03eb4be164eae24337da7ccd0b8e1f5b83c991d11 AS build

ARG VERSION=5.1.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache \
        # https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux
        build-base cmake curl git linux-headers ninja-build ninja-is-really-ninja python3 re2c tar xz \
        icu-dev openssl-dev qt6-qtbase-dev qt6-qtbase-private-dev qt6-qttools-dev zlib-dev \
        # Undocumented qBittorrent dependencies
        boost-dev \
        # Other build dependencies
        coreutils

# Checkout from source
RUN git clone --branch "$( \
        git ls-remote --tags --refs https://github.com/qbittorrent/qBittorrent.git | \
        awk -F'refs/tags/' '{print $2" "$2}' | \
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
    )" --depth 1 https://github.com/qbittorrent/qBittorrent.git

# Configure and make
# hadolint ignore=DL3003
RUN cd qBittorrent && \
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
    DESTDIR=/staging ninja install

# Staged alongside the build output so the final stage needs only one COPY
COPY entrypoint.sh qBittorrent.conf /staging/

FROM emmercm/libtorrent:2.0@sha256:813289983b76576a0fd65ce03eb4be164eae24337da7ccd0b8e1f5b83c991d11

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Install container and entrypoint dependencies, make directories, and symlink them for quality of life
# hadolint ignore=DL3018
RUN apk add --no-cache qt6-qtbase curl dumb-init tzdata && \
    mkdir -p ~/.config/qBittorrent ~/.local/share/qBittorrent /downloads /incomplete && \
    ln -s ~/.config/qBittorrent /config && \
    ln -s ~/.local/share/qBittorrent /data

COPY --from=build /staging /

VOLUME ["/config", "/data", "/downloads", "/incomplete"]

EXPOSE 8080 6881/tcp 6881/udp

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["qbittorrent-nox"]
