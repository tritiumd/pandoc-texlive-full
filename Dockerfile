# Rewrite from build pandoc from source in alpine (https://github.com/pandoc/dockerfiles/blob/master/alpine/Dockerfile)
FROM --platform=$BUILDPLATFORM alpine:edge as builder

RUN apk --no-cache add alpine-sdk bash ca-certificates cabal fakeroot \
        ghc git gmp-dev libffi libffi-dev lua5.4-dev pkgconfig yaml zlib-dev

COPY cabal.root.config /root/.cabal/config

# clone pandoc
RUN git clone --branch=3.1.12.3  --depth=1 --quiet https://github.com/jgm/pandoc /usr/src/pandoc
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

FROM --platform=$BUILDPLATFORM alpine:edge

# https://github.com/gliderlabs/docker-alpine/issues/386#issuecomment-380096034
RUN echo -e "https://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories

RUN apk --no-cache add gmp libffi lua5.4 lua5.4-lpeg librsvg fontconfig freetype gnupg gzip \
    perl tar wget xz py-pip texlive-full asymptote plantuml graphviz msttcorefonts-installer \
    nodejs npm chromium font-noto-cjk font-noto-emoji  terminus-font ttf-dejavu ttf-freefont  \
    ttf-font-awesome ttf-inconsolata ttf-linux-libertine

RUN update-ms-fonts && fc-cache -f

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# The architecture suffix may vary based on different distributions,
# particularly for musl libc based distrubions, like Alpine linux,
# where the suffix is linuxmusl
RUN TEXLIVE_ARCH="$(uname -m)-linuxmusl" && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

RUN rm -rf /var/lib/cache/* /var/lib/log/* /usr/share/groff/* /usr/share/info/* /usr/share/lintian/* /usr/share/linda/*  \
    /var/cache/man/* /usr/share/man/* /usr/share/doc/*

# Install python extension
RUN pip3 install --break-system-packages --no-cache-dir pandoc-latex-environment

# Install nodejs extension
RUN npm install -g @mermaid-js/mermaid-cli
RUN PATH="$(npm root -g)/.bin:${PATH}"

COPY --from=builder /usr/local/bin/pandoc /usr/local/bin/pandoc
COPY --from=builder /usr/local/bin/pandoc-crossref /usr/local/bin/pandoc-crossref
COPY --from=builder /usr/src/pandoc/data /usr/share/pandoc/data

# Create dir for pandoc filter and template
COPY ./pandoc /pandoc
# https://github.com/mermaid-js/mermaid-cli/blob/master/Dockerfile
COPY puppeteer-config.json /pandoc/puppeteer-config.json

RUN chmod -R 755 /pandoc

RUN mkdir /workspace
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/pandoc","--data-dir=/pandoc"]
