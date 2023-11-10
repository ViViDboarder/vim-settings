require("dark_notify").run({
    onchange = function(_)
        -- Defined in _colors
        _G.update_colors()
    end,
})
