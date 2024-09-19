local utils = require("utils")

-- Set backup on
vim.o.backup = true
vim.o.backupdir = table.concat({
    (vim.env.XDG_DATA_HOME or "") .. "/nvim/backup//",
    (vim.env.XDG_CONFIG_HOME or "") .. "/nvim/backup//",
    "~/.config/nvim/backup//",
    ".",
}, ",")

-- Set leader to space
vim.g.mapleader = " "

-- Get terminal colors and unicode working, hopefully
vim.cmd([[
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]])
vim.o.termguicolors = true
-- vim.o.term = "xterm-256color"

vim.o.number = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.virtualedit = "onemore"
vim.o.scrolljump = 5
vim.o.scrolloff = 3
-- vim.o.backspace = "2"

-- vim.o.mousehide = true
vim.o.mouse = "a"

-- Autocomplete options
vim.o.completeopt = "menuone,noinsert,noselect,preview"
vim.api.nvim_create_autocmd({ "CompleteDone" }, {
    pattern = "*",
    command = "if pumvisible() == 0 | pclose | endif",
    group = vim.api.nvim_create_augroup("close_preview", { clear = true }),
})

local has = vim.fn.has
vim.g.is_mac = (has("mac") or has("macunix") or has("gui_macvim") or vim.fn.system("uname"):find("^darwin") ~= nil)
vim.g.is_gui = (vim.g.neovide or has("gui_macvim"))

-- Require some local values
utils.require_with_local("variables")
