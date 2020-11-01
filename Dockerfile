# ref https://hub.docker.com/r/ekidd/rust-musl-builder/~/dockerfile/
FROM buildpack-deps:buster-scm

ENV RUST_VERSION=1.47.0
    DEBIAN_FRONTEND=noninteractive \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    TARGET=x86_64-unknown-linux-musl \
    OPENSSL_VERSION=1.1.1g \
    OPENSSL_DIR=/usr/local/musl/ \
    OPENSSL_INCLUDE_DIR=/usr/local/musl/include/ \
    DEP_OPENSSL_INCLUDE=/usr/local/musl/include/ \
    OPENSSL_LIB_DIR=/usr/local/musl/lib/ \
    OPENSSL_STATIC="1" \
    PKG_CONFIG_ALLOW_CROSS=true \
    PKG_CONFIG_ALL_STATIC=true \
    ZLIB_VERSION=1.2.11 \
    LIBZ_SYS_STATIC=1

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    file \
    musl-dev \
    musl-tools \
    libssl-dev \
    pkgconf \
    linux-libc-dev \
    sudo \
    xutils-dev \
    gcc-arm-linux-gnueabihf \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -s "/usr/bin/g++" "/usr/bin/musl-g++"

RUN echo "Building OpenSSL" && \
    ls /usr/include/linux && \
    mkdir -p /usr/local/musl/include && \
    ln -s /usr/include/linux /usr/local/musl/include/linux && \
    ln -s /usr/include/x86_64-linux-gnu/asm /usr/local/musl/include/asm && \
    ln -s /usr/include/asm-generic /usr/local/musl/include/asm-generic && \
    cd /tmp && \
    curl -LO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" && \
    tar xvzf "openssl-$OPENSSL_VERSION.tar.gz" && cd "openssl-$OPENSSL_VERSION" && \
    env CC=musl-gcc ./Configure no-shared no-zlib -fPIC --prefix=/usr/local/musl -DOPENSSL_NO_SECURE_MEMORY linux-x86_64 && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ make depend && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ make && \
    make install && \
    rm /usr/local/musl/include/linux /usr/local/musl/include/asm /usr/local/musl/include/asm-generic && \
    rm -r /tmp/*

RUN echo "Building zlib" && \
    cd /tmp && \
    curl -LO "http://zlib.net/zlib-$ZLIB_VERSION.tar.gz" && \
    tar xzf "zlib-$ZLIB_VERSION.tar.gz" && cd "zlib-$ZLIB_VERSION" && \
    CC=musl-gcc ./configure --static --prefix=/usr/local/musl && \
    make && make install && \
    rm -r /tmp/*

ARG user

RUN if [ $user != "root" ] && [ $user != "" ]; then \
    useradd rust --user-group --create-home --shell /bin/bash --groups sudo && \
    echo '%sudo   ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/nopasswd && \
    install -g $user -m 775 -d $RUSTUP_HOME $CARGO_HOME; \
    fi

USER ${user:-root}

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $RUST_VERSION && \
    rustup target add $TARGET && \
    rustup component add rustfmt && \
    rustup component add clippy && \
    rustup show

RUN cargo install -f cargo-audit cargo-outdated cargo-edit cargo-release cargo-bump && \
    rm -rf ${CARGO_HOME}/registry/

ADD cargo-config.toml ${CARGO_HOME}/config

WORKDIR /work
