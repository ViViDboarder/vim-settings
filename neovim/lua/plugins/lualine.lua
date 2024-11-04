-- #selene: allow(mixed_table)
local M = {}
local utils = require("utils")

-- Only return interesting ffenc (not utf-8[unix])
function M.custom_ffenc()
    local enc = vim.bo.fenc
    local format = vim.bo.fileformat
    if enc ~= "utf-8" or format ~= "unix" then
        return enc .. "[" .. format .. "]"
    end

    return ""
end

function M.mixed_indent()
    local mixed = vim.fn.search([[\v^(\t+ | +\t)]], "nw")
    if mixed > 0 then
        return "i:" .. mixed
    end
    local space_indent = vim.fn.search([[\v^ +]], "nw")
    local tab_indent = vim.fn.search([[\v^\t+]], "nw")
    if tab_indent > 0 and space_indent > 0 then
        return "i:" .. require("math").max(tab_indent, space_indent)
    end

    return ""
end

function M.trailing_whitespace()
    local line = vim.fn.search([[\s\+$]], "nw")
    if line ~= 0 then
        return "tw:" .. line
    end

    return ""
end

-- Plugin to print name of current CSV column
M.csv_col = {
    function()
        return vim.fn.CSVCol(1)
    end,
    cond = function()
        return vim.bo.filetype == "csv" and vim.fn.exists("*CSVCol") == 1
    end,
}

-- Configure lualine witha  provided theme
function M.config_lualine(theme_name)
    -- Theme name transformations
    if theme_name == nil then
        theme_name = "auto"
    elseif theme_name:find("wombat") or theme_name == "wombuddy" then
        theme_name = "wombat"
    end

    -- navic
    local code_loc = {}
    utils.try_require("nvim-navic", function(navic)
        navic.setup({
            icons = {
                Array = "𝐴 ",
                Boolean = "𝐵 ",
                Class = "ℂ ",
                Constant = "ℭ ",
                Constructor = "𝕮 ",
                Enum = "𝐸 ",
                EnumMember = "𝐸𝑀 ",
                Event = "𝐸 ",
                Field = "𝐹 ",
                File = "📄 ",
                Function = "𝑓 ",
                Interface = "𝐼 ",
                Key = "𝐾 ",
                Method = "m ",
                Module = "𝑀 ",
                Namespace = "𝑁 ",
                Null = "𝑁 ",
                Number = "𝑁 ",
                Object = "𝑂 ",
                Operator = "𝑂 ",
                Package = "📦 ",
                Property = "𝑃 ",
                String = "𝑆 ",
                Struct = "𝑆 ",
                TypeParameter = "𝑇𝑃 ",
                Variable = "𝑉 ",
            },
        })
        code_loc = { "navic" }
    end)

    require("lualine").setup({
        options = {
            theme = theme_name,
            icons_enabled = false,
            component_separators = { left = "|", right = "|" },
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(str)
                        return str:sub(1, 1)
                    end,
                },
            },
            lualine_b = { "FugitiveHead", "diff" },
            lualine_c = { { "filename", path = 1 }, code_loc, M.csv_col },
            lualine_x = { M.custom_ffenc, "filetype" },
            lualine_y = { "progress", "location" },
            lualine_z = {
                { "diagnostics", sources = { "nvim_diagnostic" } },
                { M.mixed_indent, color = { bg = "#de4f1f" } },
                { M.trailing_whitespace, color = { bg = "#de4f1f" } },
            },
        },
    })
end

return M
