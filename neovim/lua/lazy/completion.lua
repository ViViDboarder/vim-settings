-- #selene: allow(mixed_table)
local utils = require("utils")
if vim.fn.has("nvim-0.10") == 1 then
    return {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = { "rafamadriz/friendly-snippets" },

        -- use a release tag to download pre-built binaries
        version = "1.*",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "default",
                ["<C-Space>"] = { "show", "select_next" },
                ["<CR>"] = { "select_and_accept", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            signature = {
                enabled = true,
                trigger = {
                    enabled = true,
                    show_on_insert = true,
                },
                window = {
                    show_documentation = false,
                },
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                list = {
                    selection = {
                        preselect = false,
                    },
                },
                documentation = {
                    auto_show = true,
                },
                trigger = {
                    show_on_keyword = false,
                    show_on_trigger_character = false,
                },
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
        enabled = vim.fn.has("nvim-0.10") == 1,
        event = "InsertEnter *",
    }
else
    -- Fall back to cmp if blink.cmp older nvim
    return {
        "https://github.com/hrsh7th/nvim-cmp",
        dependencies = {
            {
                "https://github.com/ray-x/lsp_signature.nvim",
                lazy = true,
                opts = {
                    extra_trigger_chars = { "(", "," },
                    auto_close_after = nil,
                    -- Toggle these to use hint only
                    floating_window = true,
                    hint_enable = false,
                },
            },
            {
                "https://github.com/hrsh7th/cmp-nvim-lsp",
                commit = utils.map_version_rule({
                    [">=0.7.0"] = utils.nil_val,
                    ["<0.7.0"] = "3cf38d9c957e95c397b66f91967758b31be4abe6",
                }),
            },
            { "https://github.com/hrsh7th/cmp-buffer" },
            { "https://github.com/f3fora/cmp-spell" },
            {
                "https://github.com/saadparwaiz1/cmp_luasnip",
                commit = utils.map_version_rule({
                    [">0.7.0"] = utils.nil_val,
                    [">=0.5.0"] = "b10829736542e7cc9291e60bab134df1273165c9",
                }),
                dependencies = {
                    {
                        "https://github.com/L3MON4D3/LuaSnip",
                        version = "^2",
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                        end,
                        dependencies = {
                            { "https://github.com/rafamadriz/friendly-snippets" },
                        },
                    },
                },
            },
        },
        opts = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            return {
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
                    { name = "lazydev" },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-U>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-D>"] = cmp.mapping.scroll_docs(4),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end),
                    ["<C-Space>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            cmp.complete()
                        end
                    end),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
            }
        end,
        version = utils.map_version_rule({
            [">=0.7.0"] = "^0.0.2",
            ["<0.7.0"] = utils.nil_val,
        }),
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            [">=0.5.0"] = "bba6fb67fdafc0af7c5454058dfbabc2182741f4",
        }),
        event = "InsertEnter *",
    }
end
