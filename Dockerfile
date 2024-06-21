# Rewrite from build pandoc from source in alpine (https://github.com/pandoc/dockerfiles/blob/master/alpine/Dockerfile)
FROM alpine:latest as builder-env

RUN apk --no-cache add alpine-sdk bash ca-certificates cabal fakeroot \
        ghc git gmp-dev libffi libffi-dev lua5.4-dev pkgconfig yaml zlib-dev \
        gcc python3-dev py3-virtualenv musl-dev linux-headers

FROM builder-env as pandoc-builder

COPY cabal.root.config /root/.cabal/config

# clone pandoc
RUN git clone --branch=3.2  --depth=1 --quiet https://github.com/jgm/pandoc /usr/src/pandoc
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

FROM builder-env as python-builder
# Install python filter
RUN python -m venv /venv
ENV PATH=/venv/bin:$PATH
COPY requirements.txt /root/requirements.txt
RUN pip3 install -r /root/requirements.txt

FROM surnet/alpine-wkhtmltopdf:3.20.0-0.12.6-full as wkhtmltopdf

FROM alpine:latest

# Prepare for load repo
COPY repositories /repositories
# Load repo -> install & download font
RUN cat /repositories >> /etc/apk/repositories && \
    apk --no-cache add lua5.4-lpeg librsvg perl python3 npm texlive-full asymptote wget zip git typst groff \
    plantuml graphviz chromium font-noto-cjk-extra tar font-jetbrains-mono msttcorefonts-installer tectonic \
    && update-ms-fonts \
    && rm -rf /repositories /usr/share/man/* /usr/share/doc/* /usr/share/info/*  \
    /usr/share/texmf-dist/source /usr/share/texmf-dist/fonts/source

# load texlive font
COPY 09-texlive-fonts.conf /etc/fonts/conf.d
RUN fc-cache -r -v

# Add wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=wkhtmltopdf /lib/libwkhtmltox* /bin/

# Install python filter
COPY --from=python-builder /venv /venv

# Install nodejs extension
RUN npm install -g @mermaid-js/mermaid-cli pagedjs-cli --omit=dev && rm -rf /root/.cache /root/.npm

# Add execute to path
ENV PATH="$(npm root -g)/.bin:/venv/bin:${PATH}"

# Create dir for pandoc filter and template
COPY --chmod=755 ./pandoc /pandoc
COPY --from=pandoc-builder /usr/src/pandoc/data /usr/share/pandoc/data
# copy default data
RUN cp -rf /usr/share/pandoc/data/* /pandoc && rm -rf /usr/share/pandoc/data

RUN mkdir /workspace
WORKDIR /workspace
ARG USERDATA=/pandoc

# Copy pandoc
COPY --from=pandoc-builder /usr/local/bin/pandoc /usr/local/bin/pandoc
COPY --from=pandoc-builder /usr/local/bin/pandoc-crossref /usr/local/bin/pandoc-crossref
COPY --chmod=755 entrypoint.sh /bin/entrypoint

ENTRYPOINT ["entrypoint"]
