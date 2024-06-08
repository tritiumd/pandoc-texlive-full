--- https://github.com/jgm/pandoc/issues/1632 thanks tarleb
--- Removes notes and links
local function clean (inlines)
  return inlines:walk {
    Note = function (_) return {} end,
    Link = function (link) return link.content end,
  }
end

--- Creates an Inlines singleton containing the raw LaTeX.
local function l(text)
  return pandoc.Inlines{pandoc.RawInline('latex', text)}
end

function Header (h)
  if FORMAT:match 'latex' and h.level <= 2 and h.classes:includes 'unnumbered' then
    local title = clean(h.content)
    local secmark = h.level == 1
      and l'\\markboth{' .. title .. l'}{' .. title .. l'}'
      or l'\\markright{' .. title .. l'}' -- subsection, keep left mark unchanged
    return {h, secmark}
  end
end