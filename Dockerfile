FROM golang:1.11-alpine as builder

MAINTAINER Olaoluwa Osuntokun <lightning.engineering>

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Install dependencies and install/build lnd.
RUN apk add --no-cache \
    bash \
    build-base \
    git \
    make \
&&  pwd \
&&  git clone https://github.com/lightningnetwork/lnd.git /go/src/github.com/lightningnetwork/lnd \
&&  ls \
&&  cd /go/src/github.com/lightningnetwork/lnd \
&&  pwd \
&&  ls \
&&  go get -d ./... \
&&  make \
&&  make install

# Start a new, final image to reduce size.
FROM alpine as final

# Expose lnd ports (server, rpc).
EXPOSE 9735 10009

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/

# Add bash.
RUN apk add --no-cache \
    bash \
    git \
&&  git clone https://github.com/lightningnetwork/lnd.git /go/src/github.com/lightningnetwork/lnd

# Copy the entrypoint script.
#COPY "docker/lnd/start-lnd.sh" .
#COPY "start-lnd.sh" .

RUN ls -al /go/src/github.com/lightningnetwork/lnd/docker/lnd
RUN chmod +x /go/src/github.com/lightningnetwork/lnd/docker/lnd/start-lnd.sh

ENTRYPOINT ["/go/src/github.com/lightningnetwork/lnd/docker/lnd/start-lnd.sh"]
