local utils = require("utils")

vim.g.neovide_default_scale_factor = 1.0
vim.g.neovide_scale_factor = vim.g.neovide_default_scale_factor

utils.keymap_set({ "n", "v" }, "<C-+>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
end, { desc = "Zoom in" })
utils.keymap_set({ "n", "v" }, "<C-->", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
end, { desc = "Zoom out" })
utils.keymap_set({ "n", "v" }, "<C-0>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_default_scale_factor
end, { desc = "Zoom reset" })
