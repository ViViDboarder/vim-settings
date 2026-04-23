-- Helpers
local utils = require("utils")

utils.require_with_local("config.variables")
utils.require_with_local("config.settings")
utils.require_with_local("config.bindings")

if vim.g.neovide then
    require("config.neovide")
elseif vim.fn.has("nvim-0.12.0") == 1 then
    -- UI2 is broken with in neovide
    -- https://github.com/neovide/neovide/issues/3446
    utils.require_with_local("config.ui")
end

-- Plugins
if vim.fn.has("nvim-0.12.0") == 1 and vim.g.force_lazy ~= true then
    require("config.pack")
else
    require("config.lazy_init")
end
