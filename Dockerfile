ARG UBUNTU_VERSION=lunar
FROM --platform=$BUILDPLATFORM ubuntu:$UBUNTU_VERSION as builder

# Rewrite from build pandoc from source in ubuntu (https://github.com/pandoc/dockerfiles/blob/master/ubuntu/Dockerfile)

## Install build dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    ghc cabal-install build-essential ca-certificates curl fakeroot git libgmp-dev \
    liblua5.4-dev pkg-config zlib1g-dev

## Clean APT cache and Man pages
RUN apt-get clean && apt-get autoclean && rm -rf /var/lib/cache/* && rm -rf /var/lib/log/* /usr/share/groff/*  \
    /usr/share/info/* /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* /usr/share/man/* /usr/share/doc/*

## Clone
ARG PANDOC_REPO=https://github.com/jgm/pandoc.git
ARG PANDOC_VERSION="3.1.9"
RUN git clone --branch ${PANDOC_VERSION} --depth=1 --quiet ${PANDOC_REPO} /usr/src/pandoc
WORKDIR /usr/src/pandoc
RUN cabal v2-update -v3

## Add lua config
COPY cabal.project.freeze /usr/src/pandoc/cabal.project.freeze
COPY cabal.project.local /usr/src/pandoc/cabal.project.local

## Build with pandoc-crossref
RUN cabal v2-build --disable-tests --disable-bench \
          --jobs . pandoc-cli pandoc-crossref

RUN find dist-newstyle -name 'pandoc*' -type f -perm -u+x \
         -exec strip '{}' ';' -exec cp '{}' /usr/local/bin/ ';'

FROM --platform=$BUILDPLATFORM ubuntu:$UBUNTU_VERSION as pandoc-texlive-full
LABEL maintainer='Phan Thanh Ngoc <phanthanhngocblaplafla@gmail.com>'

# Install textlive and dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y  \
    openjdk-17-jre-headless texlive-full python3-pip git librsvg2-bin\
    liblua5.4-0 ca-certificates wget lua-lpeg libatomic1 perl tar xzdec \
    libgmp10 libpcre3 libyaml-0-2 zlib1g fontconfig gnupg gzip

## Install Microsoft font (thanks to https://stackoverflow.com/a/77216646)
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install ttf-mscorefonts-installer

## Clean APT cache and Man pages
RUN apt-get clean && apt-get autoclean && rm -rf /var/lib/cache/* && rm -rf /var/lib/log/* /usr/share/groff/*  \
    /usr/share/info/* /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* /usr/share/man/* /usr/share/doc/*

# Install pandoc
COPY --from=builder /usr/local/bin/pandoc /usr/local/bin/pandoc
COPY --from=builder /usr/local/bin/pandoc-crossref /usr/local/bin/pandoc-crossref
COPY --from=builder /usr/src/pandoc/data /usr/share/pandoc/data

# Create dir for pandoc filter and template
COPY ./pandoc /.pandoc
RUN ln -s /.pandoc /root/.pandoc

# Install python extension
RUN pip3 install --break-system-packages --no-cache-dir pandoc-latex-environment

RUN mkdir /workspace
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/pandoc"]
