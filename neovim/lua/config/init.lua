-- Helpers
local utils = require("utils")

utils.require_with_local("config.variables")
utils.require_with_local("config.settings")
utils.require_with_local("config.bindings")

if vim.g.neovide then
    require("config.neovide")
end

-- Plugins
-- require("config.lazy_init")
require("config.pack")
