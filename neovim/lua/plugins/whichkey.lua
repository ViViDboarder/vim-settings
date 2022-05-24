local M = {}

function M.configure()
    require("which-key").setup({
        triggers_blacklist = {
          i = { "j", "k", "`"},
          v = { "j", "k" },
        },
    })
end

return M
