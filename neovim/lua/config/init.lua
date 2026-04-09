-- Helpers
local utils = require("utils")

utils.require_with_local("config.variables")
utils.require_with_local("config.settings")
utils.require_with_local("config.bindings")
if vim.fn.has("nvim-0.12.0") == 1 then
    utils.require_with_local("config.ui")
end

if vim.g.neovide then
    require("config.neovide")
end

-- Plugins
if vim.fn.has("nvim-0.12.0") == 1 then
    require("config.pack")
else
    require("config.lazy_init")
end
