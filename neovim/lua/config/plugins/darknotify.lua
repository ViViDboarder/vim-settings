local utils = require("utils")

local M = {}

function M.run()
    local dark_color = utils.env_default("NVIM_COLOR_DARK", "na")
    local light_color = utils.env_default("NVIM_COLOR_LIGHT", "na")

    if dark_color ~= light_color then
        require("dark_notify").run({
            onchange = function(_)
                require("colors").update_colors()
            end,
        })
    end
end

return M
