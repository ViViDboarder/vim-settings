local icons = require("icons")

require("todo-comments").setup({
    signs = false,
    keywords = {
        FIX = {
            icon = "🩹",
        },
        TODO = {
            icon = icons.diagnostic_signs.Pencil,
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
            icon = icons.diagnostic_signs.Warn,
        },
    },
})
