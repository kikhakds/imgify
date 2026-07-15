FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang \
    libclang-rt-18-dev \
    llvm-18 \
    lcov \
    make \
    libpng-dev \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN printf '#!/bin/sh\nexec llvm-cov-18 gcov "$@"\n' > /usr/local/bin/llvm-cov-gcov.sh \
    && chmod +x /usr/local/bin/llvm-cov-gcov.sh

WORKDIR /src

COPY . /src

CMD ["make", "BUILD=release"]