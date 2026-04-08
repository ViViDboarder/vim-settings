-- Helpers
local utils = require("utils")

utils.require_with_local("config.variables")
utils.require_with_local("config.settings")
utils.require_with_local("config.bindings")
utils.require_with_local("config.ui")

if vim.g.neovide then
    require("config.neovide")
end

-- Plugins
-- TODO: I might add an if statement here for parallel support of v0.12
-- require("config.lazy_init")
require("config.pack")
