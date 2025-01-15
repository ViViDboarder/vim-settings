-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        "https://github.com/neovim/nvim-lspconfig",
        version = utils.map_version_rule({
            [">=0.8.0"] = "^1",
            [">=0.7.0"] = "v0.1.7",
            [">=0.6.1"] = "v0.1.2",
            [">=0.6.0"] = "v0.1.0",
        }),
    },
    {
        -- Language server installer
        "https://github.com/williamboman/mason.nvim",
        version = "^1",
        dependencies = {
            { "https://github.com/neovim/nvim-lspconfig" },
            { "https://github.com/williamboman/mason-lspconfig.nvim" },
        },
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonLog",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonUpdate",
        },
    },
    {
        -- Neovim language server config
        {
            "https://github.com/folke/neodev.nvim",
            version = "^3",
            dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
            ft = { "lua" },
            -- Disable for nvim 0.10 because there is lazydev
            enabled = vim.fn.has("nvim-0.10") ~= 1,
        },
        {
            "https://github.com/folke/lazydev.nvim",
            version = "^1",
            dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
            ft = "lua",
            opts = {},
            enabled = vim.fn.has("nvim-0.10") == 1,
        },
    },
    {
        -- Rust analyzer
        "https://github.com/mrcjkb/rustaceanvim",
        version = "^5",
        -- Already loads on ft
        lazy = false,
        ft = { "rust" },
        init = function()
            local lsp = require("plugins.lsp")
            vim.g.rustaceanvim = {
                server = {
                    capabilities = lsp.merged_capabilities(),
                    on_attach = lsp.get_default_attach(),
                },
            }
        end,
        enabled = vim.fn.has("nvim-0.10") == 1,
    },

    {
        -- Generic linter/formatters in diagnostics API
        "https://github.com/nvimtools/none-ls.nvim",
        -- This is lazy and configured after lsps loaded in plugins/lsp.lua
        lazy = true,
        branch = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = "0.7-compat",
            ["<0.7.0"] = utils.nil_val, -- use pinned commit
        }),
        commit = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = utils.nil_val, -- Use pinned branch
            [">=0.6.0"] = "4b403d2d724f48150ded41189ae4866492a8158b",
        }),
        dependencies = {
            { "https://github.com/nvimtools/none-ls-extras.nvim" },
            { "https://github.com/nvim-lua/plenary.nvim" },
            { "https://github.com/neovim/nvim-lspconfig" },
        },
    },
}
