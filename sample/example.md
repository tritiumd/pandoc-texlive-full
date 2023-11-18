::: beginning
Sao tự nhiên mình rảnh mà làm cái này vậy nhỉ?? Chờ build lâu quá ngồi viết nhảm. Thấy sơ xài thì đây là viết test. Tính ra là mất cũng gần 14 15 tiếng gì đó vì cái tương lai cài pandoc bằng 1 lệnh duy nhất (Nói thế thui chứ chờ mạng là chính)
:::

# Mở đầu

## Vấn đề

Mình không thích gõ word trông rất xấu, mình cũng lười gõ latex, mình thích sự đơn giản như markdown. Vậy nên mình đã quyết định tìm 1 cái gì đó để chuyển markdown sang pdf. Tadaa mình tìm thấy pandoc. Rồi mình nhận ra rằng pandoc ở mọi nơi chẳng qua mình không để ý `\faGrinBeamSweat`{=latex} . Jupyter dùng pandoc, rstudio cũng pandoc,...

Mà cài latex rất lâu nên làm cái docker image kéo 1 cái cho nhanh. Mình đã chỉnh để nó nhẹ đi rồi mà vẫn gần 6gb nhưng cứ thế xài thôi. Đã test, không có lỗi.

## Pandoc

Tóm lại là nó để chuyển đổi các dạng văn bản khác nhau hỗ trợ rất nhiều thứ. Vậy nên qua đây đọc
nhe [https://pandoc.org/MANUAL.html#options](https://pandoc.org/MANUAL.html#options)

Pandoc sẽ chuyển file md của chúng ta latex rồi sẽ gọi engine latex để compile sang pdf. Nói chung là nháp ra md rồi um ba la sì bùa ra pdf.

## Markdown

Cái tiêu chuẩn viết file text hiện tại, syntax đơn giản lại còn được pandoc cho thành pdf khá đẹp nên xài hoii. Tài liệu
nè [https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

## Docker

Nhớ cài docker nha =))

# Có gì mới so với markdown chuẩn

## Cái hộp làm màu

::: note
Lorem ipsum dolor ...
:::

## Đoạn code có caption làm màu

```{.python caption="làm màu"}
a = 3 # làm màu thui không có chi đâu
```

## Một đoạn tikz

``` {.tikz}
%%| label: delta-graph
%%| filename: delta-graph.pdf
%%| alt: Diagram showing how the delta-graph relates to the other graphs.
\tikzset{cat object/.style=   {node distance=4em}}

\begin{tikzpicture}[]
\node [cat object] (Del)                {$D$};
\node [cat object] (L)   [below of=Del] {$X$};
\node [cat object] (I)   [right of=L]   {$I$};
\node [cat object] (F)   [left of=L]    {$F$};

\draw [->] (Del) to node [left,near end]{$\scriptstyle{d_X}$}     (L);
\draw [->] (I)   to node [below]        {$\scriptstyle{x}$}       (L);
\draw [->] (Del) to node [above left]   {$\scriptstyle{d_{F}}$} (F);

\draw [->,dashed] (Del) to node {/}(I);
\end{tikzpicture}
```

## Ngắt trang nèe

`\newpage`{=latex}


## Thêm code từ file
```{.bash include=example.sh }

```

Example thế thui hết òiii còn lại tự tìm nhaa

# Reference
Cảm ơn những người đã code ra:

- pandoc 
- pandoc-crossref
- pandoc-latex-environment 
- diagram 
- multibib
- py-pandoc-include-code 
- texlive cùng các package 
- ... (Ai đó mì quên nhắc tên)

Cùng những con mò mẫm viết answer trên SO để fix bug. Mình để link người đó trong Dockerfile