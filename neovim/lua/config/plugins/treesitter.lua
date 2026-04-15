-- Configures nvim-treesitter
local M = {}

M.enable_fts = {
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
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "scala",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
}

function M.setup()
    -- NOTE: This could possibly move into ftplugin files
    local ts_gid = vim.api.nvim_create_augroup("treesitter_fts", { clear = true })
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 2
    vim.api.nvim_create_autocmd("FileType", {
        pattern = M.enable_fts,
        callback = function()
            local nvim_ts = require("nvim-treesitter")
            local installed_parsers = nvim_ts.get_installed()
            if not vim.list_contains(installed_parsers, vim.bo.filetype) then
                nvim_ts.install(vim.bo.filetype):wait(10000)
            end

            -- Enable highlighting
            vim.treesitter.start()
            -- Enable folding
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldmethod = "expr"
        end,
        group = ts_gid,
    })
end

return M
