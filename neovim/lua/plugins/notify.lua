local notify = require("notify")
local icons = require("icons")

notify.setup({
    icons = {
        ERROR = icons.diagnostic_signs.Error,
        WARN = icons.diagnostic_signs.Warn,
        DEBUG = icons.diagnostic_signs.Hint,
        TRACE = icons.diagnostic_signs.Pencil,
        INFO = icons.diagnostic_signs.Info,
    },
})

vim.notify = notify
