local M = {}

function M.config_cmp()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    cmp.setup({
        completion = {
            completeopt = "menuone,noinsert",
            autocomplete = false,
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "spell" },
            { name = "obsidian" },
            { name = "obsidian_new" },
        },
        mapping = cmp.mapping.preset.insert({
            -- Scroll docs with readline back - forward
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            -- Expand snippets with Tab
            ["<Tab>"] = cmp.mapping(function(fallback)
                if luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end),
            -- Start and cycle completions with C-Space
            ["<C-Space>"] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    cmp.complete()
                end
            end),
            -- Confirm completion with Enter
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
    })

    -- Add a plug mapping to use in C-Space binding
    local utils = require("utils")
    utils.keymap_set("i", "<Plug>(cmp_complete)", "<cmd>lua require('cmp').complete()<CR>", { desc = "Autocomplete" })

    -- Maybe add obsidian and obsidian new. This is done here in case obsidian.nvim is loaded before cmp
    utils.try_require("cmp_obsidian", function(cmp_obsidian)
        cmp.register_source("obsidian", cmp_obsidian.new())
    end)
    utils.try_require("cmp_obsidian_new", function(cmp_obsidian_new)
        cmp.register_source("obsidian_new", cmp_obsidian_new.new())
    end)
end

return M
