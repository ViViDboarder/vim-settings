local utils = require("utils")
require("notify").setup({
    icons = {
        ERROR = utils.diagnostic_signs.Error,
        WARN = utils.diagnostic_signs.Warn,
        DEBUG = utils.diagnostic_signs.Hint,
        TRACE = utils.diagnostic_signs.Pencil,
        INFO = utils.diagnostic_signs.Info,
    },
})
vim.notify = require("notify")
