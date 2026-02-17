-- #selene: allow(mixed_table)
return {
    { import = "lazy_specs.colorschemes" },
    -- Some helpers
    -- Auto and ends to some ifs and dos
    { "https://github.com/tpope/vim-endwise" },

    -- Unix commands from vim? Yup!
    { "https://github.com/tpope/vim-eunuch" },

    -- Adds repeats for custom motions
    { "https://github.com/tpope/vim-repeat" },

    -- Readline shortcuts
    { "https://github.com/tpope/vim-rsi" },

    -- Surround motions
    { "https://github.com/tpope/vim-surround" },

    -- Better netrw
    { "https://github.com/tpope/vim-vinegar" },

    -- Easier jumping to lines
    { "https://github.com/vim-scripts/file-line" },

    -- Auto ctags generation
    {
        "https://github.com/ludovicchabant/vim-gutentags",
        event = "VeryLazy",
    },

    {
        -- Better commenting
        "https://github.com/tomtom/tcomment_vim",
        keys = {
            { "//", ":TComment<CR>", desc = "Toggle comment" },
            { "//", ":TCommentBlock<CR>", mode = "v", desc = "Toggle comment" },
        },
    },
    {
        -- Allow wrapping and joining of arguments across multiple lines
        "https://git.sr.ht/~foosoft/argonaut.nvim",
        keys = {
            {
                "<Leader>a",
                function()
                    require("argonaut").reflow(true)
                end,
                desc = "Wrap or unwrap arguments",
            },
        },
    },
    {
        -- Custom status line
        "https://github.com/nvim-lualine/lualine.nvim",
        config = function()
            require("plugins.lualine").config_lualine()
        end,
        event = "VeryLazy",
    },

    -- Fuzzy Finder
    {
        "https://github.com/ibhagwan/fzf-lua",
        version = "0.0.x",
        opts = {},
        config = require("plugins.fzf-lua").setup,
        keys = {
            { "<C-t>", desc = "Find files" },
            { "<leader>b", desc = "Find buffers" },
            { "<leader>t", desc = "Find buffer tags" },
            { "<leader>*", desc = "Find strings" },
            { "<leader>s", desc = "Spell suggest" },
            { "<leader>f", desc = "Finder" },
        },
        cmd = {
            "FzfLua",
        },
        -- This also ends up getting loaded by lsp configs when bound
        lazy = true,
    },

    -- Filetypes
    {
        "https://github.com/sheerun/vim-polyglot",
        init = function()
            if not vim.g.minimal then
                vim.g.polyglot_disabled = { "go", "rust" }
            end
        end,
        config = function()
            local gid = vim.api.nvim_create_augroup("polyglot_fts", { clear = true })
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = { "*/playbooks/*.yml", "*/playbooks/*.yaml" },
                command = "set filetype=yaml.ansible",
                group = gid,
            })
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = { "go.mod", "go.sum" },
                command = "set filetype=gomod",
                group = gid,
            })
        end,
    },

    -- Debuging nvim config
    {
        "https://github.com/tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    },
}
