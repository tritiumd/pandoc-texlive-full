git clone https://github.com/tritiumd/pandoc-thesis
git clone https://github.com/tritiumd/pandoc-cv
cp -rf pandoc-*/pandoc/* pandoc
cd pandoc
(
cd csl
rm -rf .github spec *.md *.json
)
(
mv syntax-highlighting/data/syntax ./
mv syntax-highlighting/data/themes ./
rm -rf syntax-highlighting
)
