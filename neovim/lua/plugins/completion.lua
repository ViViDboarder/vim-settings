local M = {}

function M.config_cmp()
    vim.o.completeopt = "menuone,noinsert,noselect"
    local cmp = require("cmp")
    cmp.setup {
        completion = {
            completeopt = "menuone,noinsert,noselect",
            autocomplete = false,
        },
        sources = {
            {name = "nvim_lsp"},
            {name = "buffer"},
            {name = "spell"},
        },
    }

    -- Add a plug mapping to use in C-Space binding
    vim.api.nvim_set_keymap(
        "i",
        "<Plug>(cmp_complete)",
        "<cmd>lua require('cmp').complete()<CR>",
        {silent = true, noremap = true}
    )
end

-- TODO: Some issue with tags completion maybe compe is better?
function M.config_complete()
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

return M
