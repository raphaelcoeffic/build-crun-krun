FROM rust:slim-bookworm AS krun-builder

RUN apt-get update && apt-get install -y llvm libclang-dev make

ADD libkrun-1.15.1.tar.gz /src
RUN make -C /src/libkrun-1.15.1 BLK=1 NET=1 && \
    mkdir -p /dist && \
    make -C /src/libkrun-1.15.1 PREFIX=/usr DESTDIR=/dist install && \
    rm -rf /src

FROM krun-builder AS krun-dist
RUN rm -rf /dist/usr/lib64/pkgconfig

FROM debian:bookworm-slim AS crun-builder

RUN apt-get update && \
  apt-get install -y make git gcc build-essential pkgconf libtool \
   libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev \
   go-md2man autoconf python3 automake

COPY --from=krun-builder /dist/usr/include/ /usr/include
COPY --from=krun-builder /dist/usr/lib64/ /usr/lib64
COPY --from=krun-builder /dist/usr/lib64/pkgconfig/ /usr/lib/x86_64-linux-gnu/pkgconfig
RUN rm -rf /usr/lib64/pkgconfig

ADD crun-1.23.1.tar.gz /src
ADD *.patch /src

WORKDIR /src/crun-1.23.1

RUN patch -p1 < ../fix-1856.patch
RUN ./configure --with-libkrun && mkdir /dist && make install -j4 DESTDIR=/dist


FROM debian:bookworm-slim AS libkrunfw-builder
RUN apt-get update && \
  apt-get install -y curl build-essential python3-pyelftools bc kmod cpio \
  flex libncurses5-dev libelf-dev libssl-dev dwarves bison

ADD libkrunfw-4.10.0.tar.gz /src
WORKDIR /src/libkrunfw-4.10.0

RUN mkdir /dist && make all -j4 && make install -j4 DESTDIR=/dist

# final image
FROM scratch

COPY --from=crun-builder /dist/usr/local/bin /bin/
COPY --from=krun-dist /dist/usr/lib64 /lib/
COPY --from=libkrunfw-builder /dist/usr/local/lib64 /lib/
