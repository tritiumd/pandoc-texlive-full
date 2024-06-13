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

cd ../../
git submodule update --recursive --remote
docker buildx build --platform=linux/amd64,linux/arm64 . --tag pandoc-texlive-full:latest --progress=plain --no-cache --load
