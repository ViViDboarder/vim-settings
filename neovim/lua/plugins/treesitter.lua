-- Configures nvim-treesitter
require'nvim-treesitter.configs'.setup{
    incremental_selection = {enable = true},
    -- Indent appears to be broken right now
    indent = {enable = false},
    textobjects = {enable = true},
    highlight = {
        enable = true,
        disable = {},
    },
    ensure_installed = {
        "bash",
        "css",
        "fish",
        "go",
        "gomod",
        "javascript",
        "json",
        "lua",
        "python",
        "rust",
        "yaml",
    },
}
