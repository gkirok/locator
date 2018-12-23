FROM golang:1.11 as builder

# copy sources
ADD . /go/src/github.com/v3io/locator

# build the locator
RUN make -C /go/src/github.com/v3io/locator bin

FROM debian:stretch-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

COPY --from=builder /go/bin/locatorctl /usr/local/bin/locatorctl

CMD [ "locatorctl" ]
