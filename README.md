pandoc-texlive-full
===
Image based on alpine with pandoc with some extension and texlive preinstalled. Just pull and run

Available for amd64 and arm64

# Script
> Build command if you want to custom
> ```shell
> sh install-components.sh
> docker buildx build --platform=linux/amd64,linux/arm64 . --progress=plain --load
>```

> Run this command as pandoc
> ```shell
> docker run --rm -v your_path:/workspace ngocptblaplafla/pandoc-texlive-full:latest
>```

You can use alias for easier to call

**If you have permission error in Linux use this command:**
> ```shell
> docker run --rm --user `id -u`:`id -g` -v your_path:/workspace ngocptblaplafla/pandoc-texlive-full:latest
>```

# Add more component
## Python filter
- From this image add pip command e.g.
```dockerfile
RUN pip3 install --break-system-packages --no-cache-dir pandoc-latex-environment
```

## Lua filter
Mount your lua filter folder with /pandoc/filters

## Template
Mount your template folder with /pandoc/template

## Font
Mount your font folder with /usr/share/fonts/

List available font:
```bash
fc-list  | cut -d\  -f2-99 | cut -d: -f1 | sort -u
```

# Credits
- [Pandoc](https://github.com/jgm/pandoc)
- [Pandoc Team](https://github.com/pandoc) 
- [Pandoc-Ext Team](https://github.com/pandoc-ext)
- Special thank [Tarleb](https://tarleb.com) for help me a lot when I writing filter
- chrisaga for some [filter](https://github.com/chrisaga/hk-pandoc-filters)
- [pandoc-latex-template](https://github.com/Wandmalfarbe/pandoc-latex-template)
- [pandoc-leaflet-template](https://gitlab.com/daamien/pandoc-leaflet-template)
- [pandoc-letter](https://github.com/aaronwolen/pandoc-letter)
- [KDE/syntax-highlighting](https://github.com/KDE/syntax-highlighting)
- [citation-style-language/styles](https://github.com/citation-style-language/styles)
- [Tectonic](https://github.com/tectonic-typesetting/tectonic)
- [Wkhtmltopdf](https://wkhtmltopdf.org/) (thank [Surnet](https://github.com/Surnet/docker-wkhtmltopdf/) for prebuilt)
- And many answers from Github and StackOverflow I forgot