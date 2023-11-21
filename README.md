pandoc-texlive-full
===
Image based on ubuntu with pandoc with some extension and texlive preinstalled. Just pull and run

Available for amd64 and arm64

# Script
> Build command if you want to custom
> ```shell
> docker buildx build --platform=linux/amd64,linux/arm64 .
>```

> Run this command as pandoc
> ```shell
> docker run --rm -v your_path:/workspace ngocptblaplafla/pandoc-texlive-full:latest
>```

You can use alias for easier to call

# Add more component
## Python filter
- From this image add pip command e.g.
```dockerfile
RUN pip3 install --break-system-packages --no-cache-dir pandoc-latex-environment
```

## Lua filter
Mount your lua filter folder with /.pandoc/filters

## Template
Mount your template folder with /.pandoc/template

## Font
Mount your font folder with /usr/share/fonts/

# Notes
If lua filter doesn't working expectly, e.g Cannot included header, you should copy it from lua file

With `tables-rules.lua` from chrisaga/hk-pandoc-filters

```latex
\usepackage{longtable,booktabs,array,multirow}
\usepackage{calc} % for calculating minipage widths
% Correct order of tables after \paragraph or \subparagraph
\usepackage{etoolbox}
\makeatletter
\patchcmd\longtable{\par}{\if@noskipsec\mbox{}\fi\par}{}{}
\makeatother
% Allow footnotes in longtable head/foot
\IfFileExists{footnotehyper.sty}{\usepackage{footnotehyper}}{\usepackage{footnote}}
\makesavenoteenv{longtable}
\setlength{\aboverulesep}{0pt}
\setlength{\belowrulesep}{0pt}
\renewcommand{\arraystretch}{1.3}
```

# Credits
- [Pandoc](https://github.com/jgm/pandoc)
- [Pandoc Team](https://github.com/pandoc)
- [Pandoc-Ext Team](https://github.com/pandoc-ext)
- chrisaga for some [filter](https://github.com/chrisaga/hk-pandoc-filters)
