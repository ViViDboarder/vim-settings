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
    elseif theme_name:find("wombat") then
        theme_name = "wombat"
    elseif theme_name == "wombuddy" then
        theme_name = "wombat"
    end

    -- gps / navic
    local code_loc = {}

    utils.try_require("nvim-gps", function(gps)
        gps.setup({
            icons = {
                ["class-name"] = "(c) ",
                ["function-name"] = "(ƒ) ",
                ["method-name"] = "(m) ",
                ["container-name"] = "",
                ["tag-name"] = "(t) ",
            },
        })
        code_loc = { gps.get_location, cond = gps.is_available }
    end)

    utils.try_require("nvim-navic", function(navic)
        navic.setup({
            icons = {
                Class = "(c)",
                Constant = "(Const)",
                Constructor = "cst",
                Function = "(f)",
                Method = "(m)",
                Package = "(p)",
                Property = "(pr)",
                Struct = "(s)",
                Variable = "(v)",
            },
        })
        code_loc = { "navic" }
    end)

    local diagnostic_plugin = "nvim_diagnostic"
    -- HACK: Support for <0.6
    if vim.fn.has("nvim-0.6.0") ~= 1 then
        diagnostic_plugin = "nvim_lsp"
    end

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
                { "diagnostics", sources = { diagnostic_plugin } },
                { M.mixed_indent, color = { bg = "#de4f1f" } },
                { M.trailing_whitespace, color = { bg = "#de4f1f" } },
            },
        },
    })
end

return M
