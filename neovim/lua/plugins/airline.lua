local function config_airline()
    -- Use short-form mode text
    vim.g.airline_mode_map = {
        ['__'] = '-',
        ['n']  = 'N',
        ['i']  = 'I',
        ['R']  = 'R',
        ['c']  = 'C',
        ['v']  = 'V',
        ['V']  = 'V',
        [''] = 'V',
        ['s']  = 'S',
        ['S']  = 'S',
        [''] = 'S',
        ['t']  = 'T',
    }

    -- abbreviate trailing whitespace and mixed indent
    vim.g["airline#extensions#whitespace#trailing_format"] = "tw[%s]"
    vim.g["airline#extensions#whitespace#mixed_indent_format"] = "i[%s]"
    -- Vertical separators for all
    vim.g.airline_left_sep=''
    vim.g.airline_left_alt_sep=''
    vim.g.airline_right_sep=''
    vim.g.airline_right_alt_sep=''
    vim.g["airline#extensions#tabline#enabled"] = 1
    vim.g["airline#extensions#tabline#left_sep"] = " "
    vim.g["airline#extensions#tabline#left_alt_sep"] = "|"
    -- Slimmer section z
    vim.g.airline_section_z = "%2l/%L:%2v"
    -- Skip most common encoding
    vim.g["airline#parts#ffenc#skip_expected_string"] = "utf-8[unix]"
    -- If UTF-8 symbols don't work, use ASCII
    -- vim.g.airline_symbols_ascii = 1
    vim.g["airline#extensions#nvimlsp#enabled"] = 1
end

config_airline()
