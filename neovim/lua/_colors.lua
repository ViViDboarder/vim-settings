-- Update colors based on environment variables
function _G.update_colors()
    local function maybe_set(scope, name, val, force)
        force = force or false
        local changed = vim[scope][name] ~= val
        if changed or force then
            if scope == "g" and name == "colors_name" then
                -- Colorscheme is different. Use this instead of setting colors_name directly
                vim.cmd("colorscheme "..val)
            else
                vim[scope][name] = val
            end
            return changed
        end
        return false
    end

    -- Set colorscheme based on env
    local utils = require("utils")
    local default_color = "solarized"
    local env_color = utils.env_default("VIM_COLOR", default_color)
    env_color = utils.env_default("NVIM_COLOR", env_color)

    -- Read dark mode
    local mode = utils.env_default("IS_DARKMODE", "dark")
    if vim.g.is_mac == 1 then
        local cmd = "defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light"
        mode = vim.fn.system(cmd):gsub("\n", ""):lower()
    end

    -- Update background and theme
    local change = false
    if mode == "dark" then
        env_color = utils.env_default("VIM_COLOR_DARK", env_color)
        env_color = utils.env_default("NVIM_COLOR_DARK", env_color)
        change = maybe_set("o", "background", "dark")
        change = maybe_set("g", "colors_name", env_color, false) or change
    elseif mode == "light" then
        env_color = utils.env_default("VIM_COLOR_LIGHT", env_color)
        env_color = utils.env_default("NVIM_COLOR_LIGHT", env_color)
        change = maybe_set("o", "background", "light")
        change = maybe_set("g", "colors_name", env_color, false) or change
    end

    -- Update status line theme
    if change then
        if vim.fn.exists(":AirlineRefresh") == 1 then
            vim.cmd(":AirlineRefresh")
        elseif utils.is_plugin_loaded("lualine.nvim") then
            require("plugins.lualine").config_lualine()
        end
    end

    return change and "Changed color to " .. env_color .. " with mode " .. mode or "No change"
end

-- Don't need the autocommand when dark-notify is installed
local utils = require("utils")
if not utils.is_plugin_loaded("dark-notify") then
    utils.autocmd("auto_colors", "FocusGained * call v:lua.update_colors()")
end

-- Initial setting of colors
_G.update_colors()
