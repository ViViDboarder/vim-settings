local M = {}

-- Only return interesting ffenc (not utf-8[unix])
function M.custom_ffenc()
    local enc = vim.bo.fenc
    local format = vim.bo.fileformat
    if enc ~= "utf-8" or format ~= "unix" then
        return enc .. "[" .. format .. "]"
    end

    return nil
end

-- Use only single letters for mode names
function M.single_letter_mode()
    local mode_map = {
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

    return mode_map[vim.fn.mode()]
end

function M.mixed_indent()
    local mixed = vim.fn.search([[\v^(\t+ | +\t)]], 'nw')
    if mixed > 0 then
        return "i:" .. mixed
    end
    local space_indent = vim.fn.search([[\v^ +]], 'nw')
    local tab_indent = vim.fn.search([[\v^\t+]], 'nw')
    if tab_indent > 0 and space_indent > 0 then
        return "i:" .. require("math").max(tab_indent, space_indent)
    end

    return nil
end

function M.trailing_whitespace()
    local line = vim.fn.search([[\s\+$]], 'nw')
    if line ~= 0 then
        return "tw:" .. line
    end

    return nil
end

-- Configure lualine witha  provided theme
function M.config_lualine(theme_name)
    -- Theme name transformations
    if theme_name == nil then
        theme_name = "auto"
    elseif theme_name == "wombat256mod" then
        theme_name = "wombat"
    elseif theme_name == "wombuddy" then
        theme_name = "wombat"
    end

    require("lualine").setup {
        options = {
            theme = theme_name,
            icons_enabled = false,
            component_separators = {"|", "|"},
            section_separators = {"", ""},
        },
        sections = {
            lualine_a = { M.single_letter_mode },
            lualine_b = { "FugitiveHead", "diff" },
            lualine_c = { "filename" },
            lualine_x = { M.custom_ffenc, "filetype" },
            lualine_y = { "progress", "location" },
            lualine_z = {
                { "diagnostics", sources = { "nvim_lsp" } },
                { M.mixed_indent, color = { bg = "#de4f1f" } },
                { M.trailing_whitespace, color = { bg = "#de4f1f" } },
            },
        },
    }
end

return M