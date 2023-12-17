docker run --rm -v $(pwd)/sample:/workspace pandoc-texlive-full:latest \
      --pdf-engine=xelatex --listings --lua-filter include-files.lua --lua-filter tables-rules.lua  \
      --filter pandoc-crossref --filter pandoc-latex-environment --lua-filter column-div.lua  \
      --lua-filter include-code-files.lua --lua-filter multibib.lua  --lua-filter diagram.lua \
      -H example.tex example.md -s -o result.pdf

