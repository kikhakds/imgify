
FROM ubuntu:24.04
 
ENV DEBIAN_FRONTEND=noninteractive
 
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang \
    libclang-rt-18-dev \
    make \
    libpng-dev \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*
 
WORKDIR /src
 
COPY . /src
 
CMD ["make", "BUILD=release"]
