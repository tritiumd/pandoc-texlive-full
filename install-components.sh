# get data from submodule
git submodule update --recursive --remote

# install data from source
git clone --depth 1 --branch=3.3 https://github.com/jgm/pandoc srcpandoc
cp -rf srcpandoc/data/* pandoc
rm -rf srcpandoc
# install template from other source
function downloadTemplate() {
  REPO=$1
  TEMPLATE_NAME=$2
  TEMPLATE_OUT_NAME=$3
  TEMPLATE_VERSION=$4
  redownload=$5
  if [ ! -f ${EXT_NAME}.tex ] || [ $redownload = true ]
  then
      wget ${REPO}/${TEMPLATE_VERSION}/${TEMPLATE_NAME} -O ${TEMPLATE_OUT_NAME}.tex
  fi
}

(
  redownload=false
  cd pandoc/templates
  downloadTemplate "https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template" eisvogel.tex eisvogel "2.4.2" $redownload
  downloadTemplate "https://raw.githubusercontent.com/aaronwolen/pandoc-letter" template-letter.tex letter master
  downloadTemplate "https://gitlab.com/daamien/pandoc-leaflet-template/-/raw" leaflet.latex leaflet master
)

# install template from tritiumd
git clone https://github.com/tritiumd/pandoc-thesis --depth 1
git clone https://github.com/tritiumd/pandoc-cv --depth 1
cp -rf pandoc-*/pandoc/* pandoc

#clean
rm -rf pandoc-thesis pandoc-cv srcpandoc
(
cd pandoc/csl
rm -rf .github spec *.md *.json
)
(
cd pandoc/syntax-highlighting
mv data/syntax ../
mv data/themes ../
cd ../
rm -rf syntax-highlighting
)
zip -r pandoc-assets.zip pandoc
