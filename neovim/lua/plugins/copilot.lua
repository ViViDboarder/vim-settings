local utils = require("utils")
local M = {}

-- Accept copilot suggestion
function M.copilot_accept()
    local suggest = vim.fn["copilot#GetDisplayedSuggestion"]()
    if next(suggest.item) ~= nil then
        return vim.fn["copilot#Accept"]("\\<CR>")
    else
        return utils.t("<Right>")
    end
end

function M.setup()
    -- Replace keymap for copilot to accept with <C-F> and <Right>, similar to fish shell
    vim.g.copilot_no_tab_map = false
    utils.keymap_set("i", "<C-F>", M.copilot_accept, { expr = true, replace_keycodes = false, noremap = true })
    utils.keymap_set("i", "<Right>", M.copilot_accept, { expr = true, replace_keycodes = false, noremap = true })

    -- Create autocmd to disable copilot for certain filetypes that may contain sensitive information
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { ".env*", "*secret*", "*API_KEY*", "*TOKEN*" },
        command = "let b:copilot_enabled = 0",
        group = vim.api.nvim_create_augroup("CopilotDisable", {
            clear = true,
        }),
    })
end

M.setup()

return M
