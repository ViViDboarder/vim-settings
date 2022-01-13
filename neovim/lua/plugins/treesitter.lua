-- Configures nvim-treesitter
local M = {}

local ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "fish",
    "go",
    "gomod",
    "html",
    "java",
    "javascript",
    "json",
    "kotlin",
    "lua",
    "make",
    "python",
    "rust",
    "scala",
    "toml",
    "typescript",
    "vim",
    "yaml",
}

function M.bootstrap()
    require("nvim-treesitter.install").ensure_installed_sync(ensure_installed)
end

function M.setup()
    require("nvim-treesitter.configs").setup({
        incremental_selection = { enable = true },
        -- Indent appears to be broken right now
        indent = { enable = false },
        textobjects = { enable = true },
        highlight = {
            enable = true,
            disable = {},
        },
        ensure_installed = ensure_installed,
    })
end

return M
