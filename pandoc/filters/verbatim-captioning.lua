local pandoc=require('pandoc')
function Meta(meta)
    if PANDOC_WRITER_OPTIONS.listings and not FORMAT:match 'latex' then return nil end
    name = 'Verbatim'
    if meta['verbatim-floatname'] then name = meta['verbatim-floatname'] end
    includes = '\\usepackage{newfloat}\n'..
                '\\DeclareFloatingEnvironment[\n'..
                'fileext=los,\n'..
                'name='..name..',\n'..
                'placement=tbhp,\n'..
                ']{coding}'

    if meta['header-includes'] then
        table.insert(meta['header-includes'], pandoc.RawBlock('tex', includes))
    else
        meta['header-includes'] = List:new{pandoc.RawBlock('tex', includes)}
    end

    return meta
end

function CodeBlock(elem)
    if PANDOC_WRITER_OPTIONS.listings and not FORMAT:match 'latex' then return nil end
    if not elem.attributes['caption'] then return nil end
    return pandoc.RawBlock('tex','\\begin{coding}\n'
    .. pandoc.write ( pandoc.Pandoc({elem}),'latex' )
    .. '\\caption{'.. elem.attributes['caption'] ..'}\n'
    .. '\\end{coding}')
end

return {{Meta = Meta},{CodeBlock=CodeBlock}}