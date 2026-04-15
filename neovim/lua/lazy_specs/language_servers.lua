-- #selene: allow(mixed_table)
return {
    {
        "https://github.com/neovim/nvim-lspconfig",
        config = function()
            -- This should run after all the LSP plugins are installed
            require("config.plugins.lsp").setup()
        end,
    },
    {
        -- Neovim language server config
        "https://github.com/folke/lazydev.nvim",
        version = "^1",
        dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
        ft = "lua",
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                vim.env.VIMRUNTIME,
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        -- Rust analyzer
        "https://github.com/mrcjkb/rustaceanvim",
        version = "^6",
        -- Already loads on ft
        lazy = false,
        ft = { "rust" },
    },
    {
        -- Generic linter/formatters in diagnostics API
        "https://github.com/nvimtools/none-ls.nvim",
        -- This is lazy and configured after lsps loaded in plugins/lsp.lua
        lazy = true,
        dependencies = {
            { "https://github.com/nvimtools/none-ls-extras.nvim" },
            { "https://github.com/gbprod/none-ls-shellcheck.nvim" },
            { "https://github.com/nvim-lua/plenary.nvim" },
            { "https://github.com/neovim/nvim-lspconfig" },
        },
    },
}
