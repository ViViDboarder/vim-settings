local o = vim.o

-- Helpers
require("_settings")
require("_bindings")
require("_colors")

-- Use better grep programs
if vim.fn.executable("rg") == 1 then
    o.grepprg = "rg --vimgrep --no-heading --color=never"
    o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
elseif vim.fn.executable("ag") == 1 then
    o.grepprg = "ag --vimgrep --nogroup --nocolor"
elseif vim.fn.executable("ack") == 1 then
    o.grepprg = "ack"
end

-- Disable polyglot for langauges I've added special support for
-- TODO: Can this be moved somewhere better?
vim.g.polyglot_disabled = { "go", "rust" }

-- Plugins
-- Packer auto installs and then lazy loads itself on PackerCommand and require the plugins module
-- This command should only really be needed to bootstrap a new system
vim.cmd([[command! PackerBootstrap lua require("plugins")]])
