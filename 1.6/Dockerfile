FROM watawuwu/ubuntu:14.04

MAINTAINER watawuw <watawuwu@gmail.com>

RUN apt-get -y update \
  &&  apt-get -y install build-essential git gcc-arm-linux-gnueabihf make python2.7 libc6-dev-i386 --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

ENV RUST_VERSION=1.6.0

RUN cd /usr/local/src \
  &&  curl -sSf https://static.rust-lang.org/dist/rustc-${RUST_VERSION}-src.tar.gz | tar xzf - \
  &&  cd rustc-${RUST_VERSION} \
  &&  ./configure --target=x86_64-unknown-linux-gnu,arm-unknown-linux-gnueabihf \
  &&  make && make install \
  &&  rm -rf /usr/local/src/rustc-${RUST_VERSION}

RUN cd /usr/local/src \
  && FILE_NAME=cargo-nightly-x86_64-unknown-linux-gnu.tar.gz
  && curl -sSf https://static.rust-lang.org/cargo-dist/${FILE_NAME} | tar xzf - \
  &&  cd cargo-nightly-x86_64-unknown-linux-gnu \
  &&  ./install.sh \
  &&  rm -rf /usr/local/src/${FILE_NAME}

RUN mkdir /source \
  &&  mkdir .cargo \
  &&  echo "[target.arm-unknown-linux-gnueabihf]\nlinker = \"arm-linux-gnueabihf-gcc-4.8\"" > .cargo/config

WORKDIR /source

CMD ["true"]
