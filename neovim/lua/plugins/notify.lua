local utils = require("utils")

local notify = require("notify")

notify.setup({
    icons = {
        ERROR = utils.diagnostic_signs.Error,
        WARN = utils.diagnostic_signs.Warn,
        DEBUG = utils.diagnostic_signs.Hint,
        TRACE = utils.diagnostic_signs.Pencil,
        INFO = utils.diagnostic_signs.Info,
    },
})

vim.notify = notify

-- Add Telescope keymap
utils.try_require("telescope", function(telescope)
    utils.keymap_set("n", "<leader>fn", telescope.extensions.notify.notify, { desc = "Find notifications" })
end)
