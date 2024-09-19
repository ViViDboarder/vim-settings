if vim.fn.has("nvim-0.9.0") ~= 1 then
    print("ERROR: Requires nvim >= 0.9.0")
end

-- Helpers
require("default_settings")
require("default_bindings")

-- Use better grep programs
if vim.fn.executable("rg") == 1 then
    vim.o.grepprg = "rg --vimgrep --no-heading --color=never"
    vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
elseif vim.fn.executable("ag") == 1 then
    vim.o.grepprg = "ag --vimgrep --nogroup --nocolor"
elseif vim.fn.executable("ack") == 1 then
    vim.o.grepprg = "ack"
end

-- Disable polyglot for langauges I've added special support for
-- TODO: Can this be moved somewhere better?
vim.g.polyglot_disabled = { "go", "rust" }

-- Plugins
require("lazy_init")

-- Load colors after plugins
require("colors")
