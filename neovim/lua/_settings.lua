local wo = vim.wo
local o = vim.o
local bo = vim.bo
local g = vim.g

-- Set leader to space
g.mapleader = " "

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

local has = vim.fn.has
g.is_mac = (has("mac") or has("macunix") or has("gui_macvim") or vim.fn.system("uname"):find("^darwin") ~= nil)
