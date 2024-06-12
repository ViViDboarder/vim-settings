local utils = require("utils")
local M = {}

function M.copilot_accept()
    local suggest = vim.fn["copilot#GetDisplayedSuggestion"]()
    if next(suggest.item) ~= nil then
        print("accept cp")
        return vim.fn["copilot#Accept"]("\\<CR>")
    else
        return utils.t("<Right>")
    end
end

M.setup = function()
    vim.g.copilot_no_tab_map = false
    utils.keymap_set("i", "<C-F>", M.copilot_accept, { expr = true, replace_keycodes = false, noremap = true })
    utils.keymap_set("i", "<Right>", M.copilot_accept, { expr = true, replace_keycodes = false, noremap = true })
end

M.setup()

return M
