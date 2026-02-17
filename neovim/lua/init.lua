if vim.fn.has("nvim-0.9.0") ~= 1 then
    print("ERROR: Requires nvim >= 0.9.0")
end

-- Helpers
local utils = require("utils")

utils.require_with_local("variables")
utils.require_with_local("settings")
utils.require_with_local("bindings")

if vim.g.neovide then
    require("neovide")
end

-- Plugins
require("lazy_init")

-- Load colors after plugins
require("colors").init()
