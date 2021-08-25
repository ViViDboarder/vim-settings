-- TODO: Determine if keeping this
local function config_compe()
    require("compe").setup{
        enabled = true,
        autocomplete = true,
        source = {
            path = true,
            buffer = true,
            calc = true,
            tags = true,
            spell = true,
            nvim_lsp = true,
            nvim_lua = true,
        },
    }
end

-- TODO: Some issue with tags completion maybe compe is better?
local function config_complete()
    vim.o.completeopt = "menuone,noinsert,noselect"
    -- shortmess+=c
    vim.g.completion_enable_auto_popup = 0
    -- vim.api.nvim_set_keymap("i", "<C-Space>", "<Plug>(completion_trigger)", {silent=true})
    vim.g.completion_enable_auto_paren = 1
    vim.cmd([[
        augroup completionPlugin
            autocmd BufEnter * lua require('completion').on_attach()
        augroup end
    ]])
end

config_complete()
