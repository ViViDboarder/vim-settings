local M = {}

function M.config_cmp()
    local cmp = require("cmp")
    cmp.setup {
        completion = {
            completeopt = "menuone,noinsert,noselect",
            autocomplete = false,
        },
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
        sources = {
            {name = "nvim_lsp"},
            {name = "luasnip"},
            {name = "buffer"},
            {name = "spell"},
        },
        mapping = {
            ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    cmp.complete()
                end
            end, { 'i', 'c' }),
            ['<C-e>'] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
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

return M
