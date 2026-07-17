# Instructions on building qBittorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Compiling_qBittorrent_without_the_GUI_aka_qBittorrentnox_aka_headless
#   https://github.com/qbittorrent/qBittorrent/wiki/Running-qBittorrent-without-X-server#compile-from-source---how-to-disable-qbittorrents-gui
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

FROM emmercm/libtorrent:1.0@sha256:67b932b1835aad07759410aadcf643ba8d061ec06838ff602168ccd17c4f0672 AS build

ARG VERSION=3.3.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache boost-dev coreutils g++ gcc git make pkgconfig qt5-qttools-dev

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

COPY stacktrace.patch /

# Configure and make
# hadolint ignore=DL3003
RUN cd qBittorrent && \
    ./configure --disable-gui && \
    (patch -p0 -i /stacktrace.patch || true) && \
    make "-j$(nproc)" && \
    make install INSTALL_ROOT=/staging

# Staged alongside the build output so the final stage needs only one COPY
COPY entrypoint.sh qBittorrent.conf /staging/

FROM emmercm/libtorrent:1.0@sha256:67b932b1835aad07759410aadcf643ba8d061ec06838ff602168ccd17c4f0672

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Install container and entrypoint dependencies, make directories, and symlink them for quality of life
# hadolint ignore=DL3018
RUN apk add --no-cache qt5-qtbase curl dumb-init tzdata && \
    mkdir -p ~/.config/qBittorrent ~/.local/share/data/qBittorrent /downloads /incomplete && \
    ln -s ~/.config/qBittorrent /config && \
    ln -s ~/.local/share/data/qBittorrent /data

COPY --from=build /staging /

VOLUME ["/config", "/data", "/downloads", "/incomplete"]

EXPOSE 8080 6881/tcp 6881/udp

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["qbittorrent-nox"]
