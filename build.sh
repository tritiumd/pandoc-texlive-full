# Install pandoc template
cd ./pandoc/templates/
redownload=false

if [ ! -f eisvogel.tex ] || [ $redownload = true ]
then
    TEMPLATE_REPO="https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template"
    TEMPLATE_VERSION="2.4.2"
    wget ${TEMPLATE_REPO}/${TEMPLATE_VERSION}/eisvogel.tex -O eisvogel.tex
fi

if [ ! -f letter.tex ] || [ $redownload = true ]
then
    TEMPLATE_REPO="https://raw.githubusercontent.com/aaronwolen/pandoc-letter"
    TEMPLATE_VERSION="master"
    wget ${TEMPLATE_REPO}/${TEMPLATE_VERSION}/template-letter.tex -O letter.tex
fi

if [ ! -f leaflet.tex ] || [ $redownload = true ]
then
    TEMPLATE_REPO="https://gitlab.com/daamien/pandoc-leaflet-template/-/raw"
    TEMPLATE_VERSION="master"
    wget ${TEMPLATE_REPO}/${TEMPLATE_VERSION}/leaflet.latex -O leaflet.tex
fi

function downloadFilterPandocExt() {
  REPO="https://raw.githubusercontent.com/pandoc-ext"
  EXT_NAME=$1
  EXT_VERSION=$2
  redownload=$3
  if [ ! -f ${EXT_NAME}.lua ] || [ $redownload = true ]
  then
      wget ${REPO}/${EXT_NAME}/${EXT_VERSION}/_extensions/${EXT_NAME}/${EXT_NAME}.lua -O ${EXT_NAME}.lua
  fi
}

# Install pandoc lua filter
cd ../filters
downloadFilterPandocExt diagram v1 $redownload
downloadFilterPandocExt multibib dd7de577e8e9ebb58f13edc3f7615141552b02c5 $redownload

function downloadFilter() {
  REPO=$1
  EXT_NAME=$2
  EXT_VERSION=$3
  redownload=$4
  if [ ! -f ${EXT_NAME}.lua ] || [ $redownload = true ]
  then
      wget ${REPO}/${EXT_VERSION}/${EXT_NAME}/${EXT_NAME}.lua -O ${EXT_NAME}.lua
  fi
}

REPO="https://raw.githubusercontent.com/pandoc/lua-filters/"
downloadFilter $REPO include-code-files master $redownload
downloadFilter $REPO include-files master $redownload
downloadFilter $REPO abstract-to-meta master $redownload
downloadFilter $REPO author-info-blocks master $redownload

REPO="https://raw.githubusercontent.com/chrisaga/hk-pandoc-filters/main/"
downloadFilter $REPO tables-rules master $redownload
downloadFilter $REPO column-div master $redownload

cd ../../
git submodule update --recursive --remote
docker buildx build --platform=linux/amd64,linux/arm64 . --tag pandoc-texlive-full:latest --progress=plain --no-cache --load
