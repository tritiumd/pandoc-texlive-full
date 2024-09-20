# Rewrite from build pandoc from source in alpine (https://github.com/pandoc/dockerfiles/blob/master/alpine/Dockerfile)
FROM alpine:latest AS builder-env

RUN apk --no-cache add alpine-sdk curl ca-certificates fakeroot git gmp-dev musl-dev linux-headers \
         libffi libffi-dev lua5.4-dev pkgconfig yaml zlib-dev gcc python3-dev py3-virtualenv cabal
COPY cabal.root.config /root/.cabal/config

FROM builder-env AS pandoc-builder

RUN cabal v2-update -v3
# clone pandoc
RUN git clone --branch=3.4  --depth=1 --quiet https://github.com/jgm/pandoc /usr/src/pandoc
WORKDIR /usr/src/pandoc
## Add lua config
COPY cabal.project.* /usr/src/pandoc
## Build with pandoc-crossref
RUN cabal v2-build --disable-tests --disable-bench --jobs . pandoc-cli pandoc-crossref
RUN find dist-newstyle -name 'pandoc*' -type f -perm -u+x -exec strip '{}' ';' -exec cp '{}' /usr/local/bin/ ';'

FROM builder-env AS python-builder
# Install python filter
RUN python -m venv /venv
ENV PATH=/venv/bin:$PATH
RUN --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    pip3 install -r /tmp/requirements.txt

FROM surnet/alpine-wkhtmltopdf:3.20.0-0.12.6-full AS wkhtmltopdf

FROM denoland/deno:alpine-1.41.0 AS quarto-installer
RUN apk add tar
ARG QUARTO_VER="1.5.57"
ARG TARGETARCH
ADD https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VER}/quarto-${QUARTO_VER}-linux-${TARGETARCH}.tar.gz /quarto.tar.gz
RUN tar -xvzf quarto.tar.gz \
    && mv quarto-${QUARTO_VER} /quarto

FROM alpine:latest

# Load repo
COPY repositories /etc/apk/repositories
# prepare texlive font
COPY 09-texlive-fonts.conf /etc/fonts/conf.d/99-texlive-fonts.conf
# Install app & font -> install js filter -> delete unused
RUN apk --no-cache add lua5.4-lpeg librsvg perl python3 npm texlive-full asymptote wget zip git typst groff \
    plantuml graphviz chromium-swiftshader font-noto-cjk-extra tar font-jetbrains-mono msttcorefonts-installer tectonic \
    && update-ms-fonts && fc-cache -r -v \
    && npm install -g @mermaid-js/mermaid-cli pagedjs-cli --omit=dev --loglevel verbose \
    && rm -rf /repositories /usr/share/man/* /usr/share/doc/* /usr/share/info/* /root/.cache /root/.npm \
    /usr/share/texmf-dist/source /usr/share/texmf-dist/fonts/source \
    && echo 'LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/lib64" /quarto/bin/quarto $@' > /usr/local/bin/quarto && chmod +x /usr/local/bin/quarto
# Add wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmlto* /usr/local/bin
# Install python filter
COPY --from=python-builder /venv /venv
# Copy quarto
COPY --from=quarto-installer /quarto /quarto
## use instructor from https://github.com/denoland/deno_docker/blob/main/alpine.dockerfile
COPY --from=quarto-installer /usr/local/lib/* /lib64/
# Copy pandoc, filter and template
COPY --chmod=755 ./pandoc /usr/local/share/pandoc
COPY --from=pandoc-builder /usr/local/bin/pandoc* /usr/local/bin
# Add execute to path
ENV PATH="$(npm root -g)/.bin:/venv/bin:${PATH}"
WORKDIR /workspace
# Add env for filter
ENV MERMAID_CONF=/usr/local/share/pandoc/puppeteer-config.json
ENV XDG_DATA_HOME=/usr/local/share
ENV XDG_CONFIG_HOME=/tmp/tritiumd
ENV XDG_CACHE_HOME=/tmp
# Add default user
USER tritiumd
ENV HOME=/tmp/tritiumd
ENTRYPOINT ["/usr/local/bin/pandoc"]
