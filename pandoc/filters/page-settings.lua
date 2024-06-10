local List = require 'pandoc.List'

function Meta(meta)
    includes = [[
\usepackage{fancyhdr}
\usepackage{geometry}
\usepackage{typearea}
\usepackage{lastpage}
]]
      if meta['header-includes'] then
        table.insert(meta['header-includes'], pandoc.RawBlock('tex', includes))
      else
        meta['header-includes'] = List:new{pandoc.RawBlock('tex', includes)}
      end
    return meta
end

function Div(div)
    if not FORMAT:match 'latex' then return nil end
    if List.includes(div.classes,'page-settings') then
        output = '\\clearpage \n'
        -- page numbering
        if div.attr.attributes["page-numbering-style"] then
            output = output .. '\\pagenumbering{' .. div.attr.attributes["page-numbering-style"] ..'}\n'
        end
        if div.attr.attributes["page-numbering-counter"] then
            output = output .. '\\setcounter{page}{' .. div.attr.attributes["page-numbering-counter"] ..'}\n'
        end
        geometry=''
        -- margin
        if div.attr.attributes["margin-left"] then
            geometry=geometry..'left='..div.attr.attributes["margin-left"]..', \n'
        end
        if div.attr.attributes["margin-right"] then
            geometry=geometry..'right='..div.attr.attributes["margin-right"]..', \n'
        end
        if div.attr.attributes["margin-top"] then
            geometry=geometry..'top='..div.attr.attributes["margin-top"]..', \n'
        end
        if div.attr.attributes["margin-bot"] then
            geometry=geometry..'bottom='..div.attr.attributes["margin-bot"]..', \n'
        end
        -- col and size
        if List.includes(div.classes,'twocolumn') then
            geometry=geometry..'twocolumn, \n'
        end
        if div.attr.attributes["twocolumn"] then
            geometry=geometry..'twocolumn='.. div.attr.attributes["twocolumn"] ..', \n'
        end
        if List.includes(div.classes,'twoside') then
            geometry=geometry..'twoside, \n'
        end
        if div.attr.attributes["twoside"] then
            geometry=geometry..'twoside='.. div.attr.attributes["twoside"] ..', \n'
        end
        -- other
        if div.attr.attributes["geometry"] then
            geometry=geometry..div.attr.attributes["geometry"]
        end
        if geometry ~= '' then
            output = output .. '\\restoregeometry\\newgeometry{' .. geometry ..'}\n'
        end
        KOMAoptions = ''
        if div.attr.attributes["paper"] then
            KOMAoptions = KOMAoptions .. 'paper=' .. div.attr.attributes["paper"] ..', \n'
        end
        if List.includes(div.classes,'landscape') then
            KOMAoptions = KOMAoptions .. 'paper=landscape,\n'
        end
        if List.includes(div.classes,'portrait') then
            KOMAoptions = KOMAoptions .. 'paper=portrait,\n'
        end
        if KOMAoptions ~= '' then
            output = output .. '\\KOMAoptions{' .. KOMAoptions ..'}\n\\recalctypearea\n'
        end
        if div.attr.attributes["hdrstyle"] and div.attr.attributes["hdrstyle"] ~= '' then
            if div.attr.attributes["hdrstyle"] == 'tmp' then
                output = output .. '\\fancypagestyle{tmp}{\n'
                output = output .. pandoc.write ( pandoc.Pandoc({div}),'latex' ).. '\n'
                output = output .. '}\n'
            end
            output = output .. '\\thispagestyle{' .. div.attr.attributes["hdrstyle"] .. '}'
        end
        return pandoc.RawBlock('latex', output)
    end
end

