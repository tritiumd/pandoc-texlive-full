function Div(div)
    if not FORMAT:match 'latex' and not FORMAT:match 'beamer' then return nil end
    if div.attr.attributes['latex-env'] ~= nil then
        variables = ''
        if div.attr.attributes['latex-vars'] ~= nil then
            for variable in string.gmatch(div.attr.attributes['latex-vars'], '([^,]+)') do
                varibles = variables .. '[' .. variable .. ']'
            end
        end
        title=''
        if div.attr.attributes['latex-title'] ~= nil then
            title='{'.. div.attr.attributes['latex-title'] .. '}'
        end
        label=''
        if div.attr.attributes['latex-label'] ~= nil then
            label='\\label{'.. div.attr.attributes['latex-label'] .. '}'
        end
        return pandoc.RawBlock('tex',
            '\\begin'.. variables ..'{' .. div.attr.attributes['latex-env'] ..'}' .. title
            .. '\n' ..
            label
            .. '\n' ..
            pandoc.write ( pandoc.Pandoc({div}),'latex' )
            .. '\n' ..
            '\\end{' .. div.attr.attributes['latex-env'] ..'}'
        )
   end
end