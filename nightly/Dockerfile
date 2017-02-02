FROM ubuntu:16.04

ARG TOOLCHAIN=nightly

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        curl \
        file \
        git \
        musl-tools \
        sudo \
        xutils-dev \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH=/root/.cargo/bin:/usr/local/musl/bin:/usr/local/bin:/usr/bin:/bin

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
    rustup default nightly && \
    rustup target add x86_64-unknown-linux-musl

ADD cargo-config.toml /root/.cargo/config

WORKDIR /root/libs

RUN VERS=1.0.2j && \
    curl -O https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xvzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    env CC=musl-gcc ./config --prefix=/usr/local/musl && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ make depend && \
    make && sudo make install && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS

ENV OPENSSL_DIR=/usr/local/musl/ \
    OPENSSL_INCLUDE_DIR=/usr/local/musl/include/ \
    DEP_OPENSSL_INCLUDE=/usr/local/musl/include/ \
    OPENSSL_LIB_DIR=/usr/local/musl/lib/ \
    OPENSSL_STATIC=1

WORKDIR /root/src
