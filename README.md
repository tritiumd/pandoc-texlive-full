pandoc-texlive-full
===
Image based on alpine with pandoc with some extension and texlive preinstalled. Just pull and run

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
- chrisaga for some [filter](https://github.com/chrisaga/hk-pandoc-filters)
