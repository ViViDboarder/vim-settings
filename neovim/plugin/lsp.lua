local utils = require("utils")
local lsp_config = require("plugins.lsp")

-- Configure my various lsp stuffs
lsp_config.config_null_ls()
lsp_config.config_lsp_intaller()
lsp_config.config_lsp()
lsp_config.config_lsp_ui()

if utils.is_plugin_loaded("lspsaga.nvim") then
    lsp_config.config_lsp_saga()
end
