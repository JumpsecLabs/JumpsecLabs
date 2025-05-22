FROM golang:1-alpine

RUN apk --no-cache add git

ENV GOBIN=/usr/bin

ARG HUGO_VERSION

RUN go install "github.com/gohugoio/hugo@${HUGO_VERSION:-latest}"

RUN addgroup -g "${HUGO_GID:-1000}" hugo && \
  adduser -D -G hugo -u "${HUGO_UID:-1000}" hugo

USER hugo

WORKDIR /labs

VOLUME /labs
