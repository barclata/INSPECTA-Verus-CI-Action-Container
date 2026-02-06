FROM jasonbelt/microkit_domain_scheduling:latest
LABEL org.opencontainers.image.source="https://github.com/loonwerks/INSPECTA-Verus-CI-Action-Container"

#ARG RUST_VERSION=1.93.0
#ARG VERUS_VERSION=0.2026.01.30.44ebdee
ARG RUST_VERSION=1.88.0
ARG VERUS_VERSION=0.2025.09.25.04e8687
ARG MICROKIT_VERSION=1.4.1
ARG MICROKIT_INSPECTA_VERSION=v1.0

# Fetch some basics
RUN sudo apt-get update -q \
    && sudo apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        tar \
        unzip \
        vim \
        wget \
    && sudo apt-get clean autoclean \
    && sudo apt-get autoremove --yes \
    && sudo rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN sudo rm -rf /bin/sh && sudo ln -s /bin/bash /bin/sh

RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path \
            --default-toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu \
            --component "rust-src,llvm-tools,rust-analyzer,rustc-dev,rustfmt" \
            --target x86_64-unknown-linux-musl

RUN cd ~ && wget https://github.com/dornerworks/microkit/releases/download/inspecta-${MICROKIT_INSPECTA_VERSION}/microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz && \
  tar -xzf microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz && \
  rm -rf microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz microkit && \
  mv microkit-sdk-${MICROKIT_VERSION} microkit

RUN cd ~ && wget https://github.com/verus-lang/verus/releases/download/release%2F${VERUS_VERSION}/verus-${VERUS_VERSION}-x86-linux.zip && \
  unzip verus-${VERUS_VERSION}-x86-linux.zip && \
  rm -rf verus-${VERUS_VERSION}-x86-linux.zip

RUN cd ~ && wget https://github.com/mozilla/grcov/releases/download/v0.8.19/grcov-x86_64-unknown-linux-gnu.tar.bz2 && \
  tar -xvf grcov-x86_64-unknown-linux-gnu.tar.bz2 && \
  mv grcov /usr/bin/

ENV PATH=${PATH}:~/verus-x86-linux/
ENV MICROKIT_BOARD=zcu102
ENV MICROKIT_SDK=/root/microkit/
ENV MICROKIT_CONFIG=debug

# ENV PATH="$PATH:/root/.cargo/bin"
