FROM ghcr.io/qno/rack-plugin-toolchain-ctng-windows:x86_64-w64-mingw32 as ctng-windows
FROM ghcr.io/qno/rack-plugin-toolchain-ctng-linux:x86_64-ubuntu16.04 as ctng-linux

FROM ubuntu:20.04
ENV LANG C.UTF-8

ARG JOBS

# Create unprivileged user to build toolchains and plugins
RUN groupadd -g 1000 build
RUN useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash build

# Install make to run make
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends make

# Create toolchain directory
USER build
RUN mkdir -p /home/build/rack-plugin-toolchain
WORKDIR /home/build/rack-plugin-toolchain
COPY --chown=build:build Makefile /home/build/rack-plugin-toolchain/

# Install dependencies for building toolchains and plugins
USER root
RUN make dep-ubuntu
# Clean up files to free up space
RUN rm -rf /var/lib/apt/lists/*

COPY --from=ctng-windows --chown=build:build /home/build/rack-plugin-toolchain/local /home/build/rack-plugin-toolchain/local
COPY --from=ctng-linux --chown=build:build /home/build/rack-plugin-toolchain/local /home/build/rack-plugin-toolchain/local

USER build
RUN make rack-sdk-all
