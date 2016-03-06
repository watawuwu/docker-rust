FROM ubuntu:latest

RUN apt-get -y update \
  &&  apt-get -y install git \
                       gcc-arm-linux-gnueabihf \
                       make \
                       curl \
                       python2.7 \
                       g++  --no-install-recommends

ENV RUST_VERSION=1.7.0

RUN cd /tmp \
  &&  curl -sSf https://static.rust-lang.org/dist/rustc-${RUST_VERSION}-src.tar.gz | tar xzf - \
  &&  cd rustc-${RUST_VERSION} \
  &&  ./configure --target=x86_64-unknown-linux-gnu,arm-unknown-linux-gnueabihf \
  &&  make && make install \
  &&  cd ../ \
  &&  rm -rf rustc-${RUST_VERSION}

RUN cd /tmp \
  && curl -sSf https://static.rust-lang.org/cargo-dist/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz | tar xzf - \
  && cd cargo-nightly-x86_64-unknown-linux-gnu \
  && ./install.sh \
  && cd ../ \
  && rm -rf cargo-nightly-x86_64-unknown-linux-gnu

RUN mkdir source \
  &&  mkdir .cargo \
  &&  echo "[target.arm-unknown-linux-gnueabihf]\nlinker = \"arm-linux-gnueabihf-gcc-4.8\"" > .cargo/config

WORKDIR source

CMD ["bash"]
