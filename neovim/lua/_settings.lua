local o = vim.o
local g = vim.g
local utils = require("utils")

-- Set leader to space
g.mapleader = " "

vim.cmd([[
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]])
o.termguicolors = true
o.number = true
o.expandtab = true
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.virtualedit = "onemore"
o.scrolljump = 5
o.scrolloff = 3
-- o.term = "xterm-256color"
-- o.backspace = "2"

-- o.mousehide = true
o.mouse = "a"

-- Autocomplete options
o.completeopt = "menuone,noinsert,noselect,preview"
utils.augroup("close_preview", function()
    vim.cmd("autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif")
end)

local has = vim.fn.has
g.is_mac = (has("mac") or has("macunix") or has("gui_macvim") or vim.fn.system("uname"):find("^darwin") ~= nil)
