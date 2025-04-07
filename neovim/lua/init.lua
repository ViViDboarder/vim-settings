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

if vim.g.neovide then
    require("neovide")
end

-- Plugins
require("lazy_init")

-- Load colors after plugins
require("colors").init()
