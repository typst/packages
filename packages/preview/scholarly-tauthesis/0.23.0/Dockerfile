FROM alpine:3.22.4

# Install requirements.

RUN apk add --no-cache \
  curl \
  python3

# Install a released version of Typst.

ARG typst_version=0.15.0

RUN \
  curl -sL https://github.com/typst/typst/releases/download/v$typst_version/typst-x86_64-unknown-linux-musl.tar.xz \
  | tar -xJ \
  && cp typst-x86_64-unknown-linux-musl/typst /usr/local/bin \
  && rm -rf typst-x86_64-unknown-linux-musl

# Set up non-root user.

RUN adduser -D -h /home/typst-user typst-user

USER typst-user

# Make sure HOME is set correctly for local package testing.

ENV HOME=/home/typst-user
