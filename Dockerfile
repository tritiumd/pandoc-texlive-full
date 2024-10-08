# Rewrite from build pandoc from source in alpine (https://github.com/pandoc/dockerfiles/blob/master/alpine/Dockerfile)
FROM alpine:latest AS builder-env

RUN apk --no-cache add alpine-sdk curl ca-certificates fakeroot git gmp-dev musl-dev linux-headers \
         libffi libffi-dev lua5.4-dev pkgconfig yaml zlib-dev gcc python3-dev py3-virtualenv cabal
COPY cabal.root.config /root/.cabal/config

FROM builder-env AS pandoc-builder

# clone pandoc
RUN git clone --branch=3.4  --depth=1 --quiet https://github.com/jgm/pandoc /usr/src/pandoc
RUN cabal v2-update -v3
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

FROM alpine:latest AS quarto-installer
RUN apk add tar
ARG QUARTO_VER="1.5.57"
ARG TARGETARCH
ADD https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VER}/quarto-${QUARTO_VER}-linux-${TARGETARCH}.tar.gz /quarto.tar.gz
RUN tar -xvzf quarto.tar.gz \
    && mv quarto-${QUARTO_VER} /quarto

FROM builder-env AS R-builder
RUN apk add R R-dev
RUN Rscript -e "install.packages(c('knitr', 'rmarkdown'), repos='https://cran.rstudio.com')"

FROM gcr.io/distroless/cc AS gnu-lib

FROM alpine:latest

# Load repo
COPY repositories /etc/apk/repositories
# prepare texlive font
COPY 09-texlive-fonts.conf /etc/fonts/conf.d/99-texlive-fonts.conf
# Install app & font -> install js filter -> delete unused
RUN apk --no-cache add lua5.4-lpeg librsvg perl python3 npm texlive-full asymptote wget zip git typst groff R R-dev \
    plantuml graphviz chromium-swiftshader font-noto-cjk-extra tar font-jetbrains-mono msttcorefonts-installer tectonic \
    && update-ms-fonts && fc-cache -r -v \
    && npm install -g @mermaid-js/mermaid-cli pagedjs-cli --omit=dev --loglevel verbose \
    && rm -rf /repositories /usr/share/man/* /usr/share/doc/* /usr/share/info/* /root/.cache /root/.npm \
    /usr/share/texmf-dist/source /usr/share/texmf-dist/fonts/source
# Add wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmlto* /usr/local/bin
# Install python filter
COPY --from=python-builder /venv /venv
# Copy quarto
COPY --from=quarto-installer /quarto /quarto
## use instructor from https://github.com/denoland/deno_docker/blob/main/alpine.dockerfile
COPY --from=gnu-lib --chown=root:root --chmod=755 /lib/*-linux-gnu/* /lib64/
# Copy pandoc, filter and template
COPY --chmod=755 ./pandoc /usr/local/share/pandoc
COPY --from=pandoc-builder /usr/local/bin/pandoc* /usr/local/bin
# Copy R lib
COPY --from=R-builder /usr/lib/R/library /usr/lib/R/library
# Add execute to path
ENV PATH="/quarto/bin:$(npm root -g)/.bin:/venv/bin:${PATH}"
ENV LD_LIBRARY_PATH=/lib:/usr/lib:/lib64
WORKDIR /workspace
# Add env for filter
ENV MERMAID_CONF=/usr/local/share/pandoc/puppeteer-config.json
ENV XDG_DATA_HOME=/usr/local/share
ENV HOME=/tmp/tritiumd
ENV XDG_CONFIG_HOME=$HOME/.config
ENV XDG_CACHE_HOME=$HOME/.cache
# Add env to enviroment
## https://stackoverflow.com/questions/34630571/docker-env-variables-not-set-while-log-via-shell
RUN env | egrep -v "^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)" | sed 's/^/export /' >> /etc/profile
# Add default user
RUN adduser --disabled-password tritiumd && chmod 777 /workspace
USER tritiumd
ENTRYPOINT ["/usr/local/bin/pandoc"]
