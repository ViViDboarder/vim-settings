local o = vim.o
local g = vim.g
local utils = require("utils")

-- Set backup on
o.backup = true
o.backupdir = table.concat({
    (vim.env.XDG_DATA_HOME or "") .. "/nvim/backup//",
    (vim.env.XDG_CONFIG_HOME or "") .. "/nvim/backup//",
    "~/.config/nvim/backup//",
    ".",
}, ",")

-- Set leader to space
g.mapleader = " "

-- Get terminal colors and unicode working, hopefully
vim.cmd([[
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]])
o.termguicolors = true
-- o.term = "xterm-256color"

o.number = true
o.expandtab = true
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.virtualedit = "onemore"
o.scrolljump = 5
o.scrolloff = 3
-- o.backspace = "2"

-- o.mousehide = true
o.mouse = "a"

-- Autocomplete options
o.completeopt = "menuone,noinsert,noselect,preview"
-- TODO: remove check when dropping v0.6.0
if vim.fn.has("nvim-0.7.0") == 1 then
    vim.api.nvim_create_autocmd({ "CompleteDone" }, {
        pattern = "*",
        command = "if pumvisible() == 0 | pclose | endif",
        group = vim.api.nvim_create_augroup("close_preview", { clear = true }),
    })
else
    utils.autocmd("close_preview", "CompleteDone * if pumvisible() == 0 | pclose | endif", true)
end

local has = vim.fn.has
g.is_mac = (has("mac") or has("macunix") or has("gui_macvim") or vim.fn.system("uname"):find("^darwin") ~= nil)
g.is_gui = vim.fn.exists("g:neovide")

-- Require some local values
utils.require_with_local("variables")
