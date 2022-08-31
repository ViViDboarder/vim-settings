local utils = require("utils")

require("todo-comments").setup({
    signs = false,
    keywords = {
        FIX = {
            icon = "🩹",
        },
        TODO = {
            icon = utils.diagnostic_signs.Pencil,
        },
        HACK = {
            icon = "🙈",
        },
        PERF = {
            icon = "🚀",
        },
        NOTE = {
            icon = "📓",
        },
        WARNING = {
            icon = utils.diagnostic_signs.Warn,
        },
    },
})
