local function stringify(v)
    pstringify = (require 'pandoc.utils').stringify
    if (v ~= nil or v ~= '')
    then
        return pstringify(v)
    else
        return ''
    end
end

local function frame(frame_type,frame_ext)
    local frame_template = {
        ['0'] = '',
        [''] = '',
        ['1'] = [[
        \begin{tikzpicture}[remember picture,overlay]
        \centering
        \draw[blue!70!black,line width=4pt]
        ([xshift=-\rmar+1cm,yshift=-\tmar+0.5cm]current page.north east) coordinate (A)--
        ([xshift=\lmar+0.5cm,yshift=-\tmar+0.5cm]current page.north west) coordinate(B)--
        ([xshift=\lmar+0.5cm,yshift=\bmar-0.5cm]current page.south west) coordinate (C)--
        ([xshift=-\rmar+1cm,yshift=\bmar-0.5cm]current page.south east) coordinate(D)--cycle;
        \draw
        ([xshift=-0.5cm,yshift=0.5cm]A)--
        ([xshift=0.5cm,yshift=0.5cm]B)--
        ([xshift=0.5cm,yshift=-0.5cm]B)--
        ([xshift=-0.5cm,yshift=-0.5cm]B)--
        ([xshift=-0.5cm,yshift=0.5cm]C)--
        ([xshift=0.5cm,yshift=0.5cm]C)--
        ([xshift=0.5cm,yshift=-0.5cm]C)--
        ([xshift=-0.5cm,yshift=-0.5cm]D)--
        ([xshift=-0.5cm,yshift=0.5cm]D)--
        ([xshift=0.5cm,yshift=0.5cm]D)--
        ([xshift=0.5cm,yshift=-0.5cm]A)--
        ([xshift=-0.5cm,yshift=-0.5cm]A)--
        ([xshift=-0.5cm,yshift=0.5cm]A);
        \draw
        ([xshift=0.3cm,yshift=-0.3cm]A)--
        ([xshift=-0.3cm,yshift=-0.3cm]B)--
        ([xshift=-0.3cm,yshift=0.3cm]B)--
        ([xshift=0.3cm,yshift=0.3cm]B)--
        ([xshift=0.3cm,yshift=-0.3cm]C)--
        ([xshift=-0.3cm,yshift=-0.3cm]C)--
        ([xshift=-0.3cm,yshift=0.3cm]C)--
        ([xshift=0.3cm,yshift=0.3cm]D)--
        ([xshift=0.3cm,yshift=-0.3cm]D)--
        ([xshift=-0.3cm,yshift=-0.3cm]D)--
        ([xshift=-0.3cm,yshift=0.3cm]A)--
        ([xshift=0.3cm,yshift=0.3cm]A)--
        ([xshift=0.3cm,yshift=-0.3cm]A);
        \end{tikzpicture}
        \indent
        ]],
        ['2'] = [[
        \begin{tikzpicture}[remember picture,overlay]
        \centering
        \draw [line width=2pt]
        ([xshift=\lmar+0.5cm,yshift=-\tmar]current page.north west)
        rectangle
        ([xshift=-\rmar+0.5cm,yshift=\bmar]current page.south east);
        \draw [line width=0.5pt]
        ([xshift=\lmar+0.6cm,yshift=-\tmar-0.1cm]current page.north west)
        rectangle
        ([xshift=-\rmar+0.4cm,yshift=\bmar+0.1cm]current page.south east);
        \end{tikzpicture}
        ]],
        ['3'] = [[
        \begin{tikzpicture}[remember picture,overlay]
        \centering
        \draw[line width = 3pt]
        ([xshift=\lmar+0.5cm,yshift=-\tmar]current page.north west)
        rectangle
        ([xshift=-\rmar+0.5cm,yshift=\bmar]current page.south east);
        \end{tikzpicture}
        \indent
        ]]
    }
    return frame_template[frame_type] .. frame_ext .. '\n'
end

local function content(meta, content_type, content)
    local content_template = {
        ['0'] = '',
        [''] = '',
        ['1'] = [[
            \centering
            \fontsize{14}{16}\selectfont{
            $university$ \\
            $if(collage)$$collage$ \\$endif$
            }
            \fontsize{13}{16}\selectfont\textbf{$faculty$} \\
            $if(horizontal_line)$$horizontal_line$\\$endif$
            \vspace*{1.5cm}
            $if(logo)$\includegraphics[height=3cm,keepaspectratio]{"$logo$"}\\$endif$
            \vspace*{1.5cm}
            \fontsize{18}{1}\selectfont \textbf{$title$} \\
            \vspace{2cm}
            \fontsize{14}{14}\selectfont{
            $if(subtitle)$ $subtitle$  \\$endif$
            $if(subject)$ $subject$  \\$endif$
            $if(major)$Ngành: $major$  \\$endif$
            }
            \vspace{2cm}
            $if(instructors)${\fontsize{14}{14}\selectfont\textbf{
            \begin{tabular}{ll}
            Người hướng dẫn: $for(instructors)$ & $instructors$$sep$ \\  $endfor$
            \end{tabular}
            }}
            \\$endif$
            \vspace{2cm}
            \raggedright{\hspace{4.2cm}\fontsize{14}{1}\selectfont \textbf{Người thực hiện:}\\
            \vspace{0.5cm}\hspace{5.5cm}
            \begin{tabular}{ll}
            $for(author)$$author.name$ & $author.id$ \\  $endfor$
            \end{tabular}
            }
            \vfill
            \centering
            \fontsize{14}{14}\selectfont{\textbf{$position$$if(year)$ - $year$$endif$}}
            \\\vspace{0.3cm}
        ]],
        ['2'] = [[
           \centering
           \fontsize{13}{13}\selectfont{
           $university$ \\
           $if(collage)$$collage$ \\$endif$
           \textbf{$faculty$}
           }
           \\
           \vspace{2.5cm}
           {\fontsize{14}{14}\selectfont \textbf{
           \begin{tabular}{ll}
           $for(author)$$author.name$ \\  $endfor$
           \end{tabular}
           }}
           \\
           \vspace{2cm}

           {\fontsize{18}{1}\selectfont\textbf{$title$} }
           \vfill
           \fontsize{14}{14}\selectfont{
           $if(subtitle)$ $subtitle$  \\$endif$
           $if(major)$ Ngành: $major$  \\$endif$
           }
           \vfill
           \centering
           \fontsize{14}{14}\selectfont{\textbf{$position$$if(year)$ - $year$$endif$}}
           \\\vspace{0.3cm}
        ]],
        ['3'] = [[
            \centering
            \fontsize{13}{13}\selectfont{
            $university$ \\
            $if(collage)$ $collage$ \\$endif$
            \textbf{$faculty$}
            }
            \\
            \vspace{2.5cm}
            {\fontsize{14}{14}\selectfont \textbf{
            \begin{tabular}{ll}
            $for(author)$$author.name$ \\  $endfor$
            \end{tabular}
            }}
            \\
            \vspace{2cm}

            {\fontsize{18}{1}\selectfont \textbf{$title$} }
            \vfill
            \fontsize{14}{14}\selectfont{
            $if(subtitle)$ $subtitle$  \\$endif$
            $if(major)$Ngành: $major$ \\$endif$
            }
            \vfill
            {\fontsize{14}{14}\selectfont \textbf{
            \begin{tabular}{ll}
            Cán bộ hướng dẫn: $for(instructors)$ & $instructors$$sep$ \\  $endfor$
            \end{tabular}
            }}
            \vfill
            \centering
            \fontsize{14}{14}\selectfont{\textbf{$position$$if(year)$ - $year$$endif$}}
            \\\vspace{0.3cm}
        ]]
    }
    return '\\begin{centerboxed}[\\centerboxedHeight]' .. '\n' ..
        pandoc.write(
              pandoc.Pandoc({pandoc.RawBlock('latex', '')}, meta),
              'latex',
              {template = pandoc.template.compile(content_template[content_type])}
            )
        .. '\n' ..
        content
        .. '\n' ..
        '\\end{centerboxed}'
end

local function cover(meta, cover_info)
    cover=''
    for i,d in ipairs(cover_info) do
        cover = cover .. '\\begin{titlepage}\n'
        if d.frame == nil then d.frame = '' end
        cover = cover .. frame(stringify(d.frame_type),pandoc.write(pandoc.Pandoc(d.frame),'latex'))
        meta.horizontal_line=d.horizontal_line
        if d.content == nil then d.content = '' end
        cover = cover .. content(meta, stringify(d.content_type),pandoc.write(pandoc.Pandoc(d.content),'latex'))
        cover = cover .. '\\end{titlepage}\n'
        if meta.twoside then
            cover = cover .. '\\newpage\n'
        end
    end
    return cover
end

local position = ''
local day = ''
local month = ''
local year = ''
local firstauthor = ''

function Meta(meta)
    meta.firstauthor = meta.author[1].name
    position = meta.position
    day = meta.day
    month = meta.month
    year = meta.year
    firstauthor = meta.firstauthor
    if not FORMAT:match 'latex' then
       author = {}
       for i,d in ipairs(meta.author) do
           table.insert(author, stringify(d.name) .. ' - ' .. stringify(d.id))
       end
       meta.author=author
    end
    if FORMAT:match 'latex' then
        meta.cover_final=pandoc.RawBlock('latex', cover(meta, meta.cover))
    end
    return meta
end

function Div(div)
    if not FORMAT:match 'latex' then
        if div.attr.attributes['latex-env'] == 'sign' then
            sign = '<div style="height: fit-content"><div style="float: right;text-align:center"> \n <i>'
            sign = sign .. stringify(position) .. ', '
            sign = sign .. 'ngày ' .. stringify(day) .. ' '
            sign = sign .. 'tháng ' .. stringify(month) .. ' '
            sign = sign .. 'năm ' .. stringify(year) .. ' '
            sign = sign .. '</i> <br>\n'
            sign = sign .. pandoc.write(pandoc.Pandoc(div),'html') ..'<br>\n'
            sign = sign .. stringify(firstauthor)..'<br>\n'
            sign = sign .. '</div></div></br>'
            return pandoc.RawBlock('html', sign)
        end
    end
end

return {
  { Meta = Meta },
  { Div = Div }
}
