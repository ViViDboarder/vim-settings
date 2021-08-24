local o, wo, bo = vim.o, vim.wo, vim.bo

-- Helpers

require "_settings"
require "_bindings"
utils = require("utils")

-- Modify visual presentation

-- Create commands
vim.cmd "command! TagsUpdate !ctags -R ."
vim.cmd "command! Todo grep TODO"

-- Use better grep programs
if vim.fn.executable('rg') == 1 then
    vim.o.grepprg = "rg --vimgrep --no-heading --color=never"
    vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
elseif vim.fn.executable('ag') == 1 then
    vim.o.grepprg = "ag --vimgrep --nogroup --nocolor"
elseif vim.fn.executable('ack') == 1 then
    vim.o.grepprg = "ack"
end

-- TODO: Determine if I want to keep this or remove it in favor of dark-notify
_G.update_colors = function()
    local function maybe_set(scope, name, val)
        if vim[scope][name] ~= val then
            vim[scope][name] = val
            return true
        end
        return false
    end

    -- Set colorscheme based on env
    local default_color = "solarized"
    local env_color = utils.env_default("VIM_COLOR", default_color)

    -- Set background from dark mode
    local darkmode = vim.env.IS_DARKMODE
    if vim.g.is_mac == 1 then
        cmd = "defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light"
        darkmode = vim.fn.system(cmd):gsub("\n", ""):lower()
    end

    local change = false
    if darkmode == "dark" then
        env_color = utils.env_default("VIM_COLOR_DARK", env_color)
        change = maybe_set("o", "background", "dark")
        change = maybe_set("g", "colors_name", env_color) or change
    elseif darkmode == "light" then
        env_color = utils.env_default("VIM_COLOR_LIGHT", env_color)
        change = maybe_set("o", "background", "light")
        change = maybe_set("g", "colors_name", env_color) or change
    end

    if change and vim.fn.exists(":AirlineRefresh") == 1 then
        vim.cmd(":AirlineRefresh")
    end

    return changed and "Changed color to " .. env_color .. " with mode " .. darkmode or "No change"
end
-- utils.autocmd("auto_colors", "FocusGained * call v:lua.update_colors()")

-- Initial set of colors
-- TODO: if update_colors() is removed, use the env color fetching and set the colorscheme here
update_colors()

require("plugins")
