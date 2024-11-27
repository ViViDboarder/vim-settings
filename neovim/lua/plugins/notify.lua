local utils = require("utils")
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

-- Add Telescope keymap
utils.try_require("telescope", function(telescope)
    utils.keymap_set("n", "<leader>fn", telescope.extensions.notify.notify, { desc = "Find notifications" })
end)
