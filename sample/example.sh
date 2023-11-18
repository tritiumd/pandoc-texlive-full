docker run --rm -v $(pwd)/sample:/workspace pandoc-texlive-full:latest \
      --pdf-engine=xelatex --listings --fail-if-warnings\
      --filter pandoc-crossref --filter pandoc-latex-environment --filter py-pandoc-include-code \
      --lua-filter multibib.lua --lua-filter diagram.lua \
      -H example.tex --metadata-file=example.yaml example.md -s -o result.pdf

