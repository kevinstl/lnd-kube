#FROM golang:1.10-alpine as builder
#FROM golang:1.10-alpine
FROM golang:1.12.0-alpine3.9

MAINTAINER Olaoluwa Osuntokun <lightning.engineering>

# Copy in the local repository to build from.
#COPY . /go/src/github.com/lightningnetwork/lnd

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

## Install dependencies and install/build lnd.
#RUN apk add --no-cache \
#    git \
#    make \
#&&  cd /go/src/github.com/lightningnetwork/lnd \
#&&  make \
#&&  make install

# Install dependencies and install/build lnd.
RUN apk add --no-cache \
#    bash \
    build-base \
    git \
    make \
&&  pwd \
&&  git clone https://github.com/lightningnetwork/lnd.git /go/src/github.com/lightningnetwork/lnd \
&&  ls \
&&  cd /go/src/github.com/lightningnetwork/lnd \
#&&  git fetch \
#&&  git checkout tags/v0.5.2-beta \
&&  pwd \
&&  ls -al  \
&&  go get -d ./... \
#&&  make || true \
&&  make \
#&&  make install || true
&&  make install

# Start a new, final image to reduce size.
#FROM alpine as final

# Expose lnd ports (server, rpc).
EXPOSE 9735 10009

# Copy the binaries and entrypoint from the builder image.
#COPY --from=builder /go/bin/lncli /bin/
#COPY --from=builder /go/bin/lnd /bin/

RUN cp /go/bin/lncli /bin/
RUN cp /go/bin/lnd /bin/

# Add bash.
RUN apk add --no-cache \
    bash

# Copy the entrypoint script.
#COPY "docker/lnd/start-lnd.sh" .
#RUN chmod +x start-lnd.sh
#
#ENTRYPOINT ["/start-lnd.sh"]


#COPY "docker/lnd.conf" /root/.lnd/
COPY "docker/start-lnd.sh" /go/src/github.com/lightningnetwork/lnd/docker/lnd/

RUN ls -al /go/src/github.com/lightningnetwork/lnd/docker/lnd
RUN chmod +x /go/src/github.com/lightningnetwork/lnd/docker/lnd/start-lnd.sh

#RUN mkdir -p "/mnt/lk/shared/rpc"

ENTRYPOINT ["/go/src/github.com/lightningnetwork/lnd/docker/lnd/start-lnd.sh"]