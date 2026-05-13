-- #selene: allow(mixed_table)
return {
    {
        src = "https://github.com/neovim/nvim-lspconfig",
        after = function()
            -- This should run after all the LSP plugins are installed
            require("config.plugins.lsp").setup()
        end,
    },
    {
        -- Neovim language server config
        src = "https://github.com/folke/lazydev.nvim",
        version = vim.version.range("^1"),
        dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
        after = function()
            require("lazydev").setup({
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    vim.env.VIMRUNTIME,
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            })
        end,
    },
    {
        -- Rust analyzer
        src = "https://github.com/mrcjkb/rustaceanvim",
        version = vim.version.range("^6"),
    },
    {
        -- Generic linter/formatters in diagnostics API
        src = "https://github.com/nvimtools/none-ls.nvim",
        -- This is lazy and configured after lsps loaded in plugins/lsp.lua
        dependencies = {
            { "https://github.com/nvimtools/none-ls-extras.nvim" },
            { "https://github.com/gbprod/none-ls-shellcheck.nvim" },
            { "https://github.com/nvim-lua/plenary.nvim" },
            { "https://github.com/neovim/nvim-lspconfig" },
        },
    },
}
