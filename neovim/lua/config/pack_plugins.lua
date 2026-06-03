local utils = require("utils")
local packle = require("packle")

-- Installed packs below
packle.add({
    {
        src = "https://github.com/ViViDboarder/wombat.nvim",
        after = function()
            require("config.colors").init()
        end,
    },
})

-- Oldies but goodies
packle.add({
    { src = "https://github.com/tpope/vim-endwise", lock = true },
    -- Unix commands from vim? Yup!
    { src = "https://github.com/tpope/vim-eunuch", lock = true },
    -- Adds repeats for custom motions
    { src = "https://github.com/tpope/vim-repeat", lock = true },
    -- Readline shortcuts
    { src = "https://github.com/tpope/vim-rsi", lock = true },
    -- Surround motions
    { src = "https://github.com/tpope/vim-surround", lock = true },
    -- Better netrw
    { src = "https://github.com/tpope/vim-vinegar", lock = true },
    -- Easier jumping to lines
    { src = "https://github.com/vim-scripts/file-line", lock = true },
    -- Auto ctags generation
    { src = "https://github.com/ludovicchabant/vim-gutentags", lock = true },
    -- Debug startup time
    { src = "https://github.com/tweekmonster/startuptime.vim", lock = true },
})

-- tcomment and keys
packle.add({
    src = "https://github.com/tomtom/tcomment_vim",
    after = function()
        utils.keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
        utils.keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })
    end,
    lock = true,
})

-- argwrapping
packle.add({
    src = "https://git.sr.ht/~foosoft/argonaut.nvim",
    after = function()
        utils.keymap_set("n", "<Leader>a", function()
            require("argonaut").reflow(true)
        end, { desc = "Wrap or unwrap arguments" })
    end,
})

-- FZF lua
packle.add({
    src = "https://github.com/ibhagwan/fzf-lua",
    after = function()
        require("config.plugins.fzf-lua").setup()
    end,
})

-- Polyglot
packle.add({
    src = "https://github.com/sheerun/vim-polyglot",
    after = function()
        if not vim.g.minimal then
            vim.g.polyglot_disabled = { "go", "rust" }
        end
        local polyglot_fts_gid = vim.api.nvim_create_augroup("polyglot_fts", { clear = true })
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = {
                "*/playbooks/*.yml",
                "*/playbooks/*.yaml",
                "*/roles/*.yml",
                "*/roles/*.yaml",
            },
            command = "set filetype=yaml.ansible",
            group = polyglot_fts_gid,
        })
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = { "go.mod", "go.sum" },
            command = "set filetype=gomod",
            group = polyglot_fts_gid,
        })
    end,
})

-- Lualine
packle.add({
    src = "https://github.com/nvim-lualine/lualine.nvim",
    after = function()
        require("config.plugins.lualine").config_lualine()
    end,
})

-- A little less minimial

-- Fugitive
packle.add({
    {
        src = "https://github.com/tpope/vim-fugitive",
        version = vim.version.range("^3"),
        after = function()
            utils.keymap_set("n", "gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
            utils.keymap_set("n", "gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
            utils.keymap_set("n", "gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
            utils.keymap_set("n", "gs", "<cmd>Git<CR>", { desc = "Git status" })
            utils.keymap_set("n", "gw", "<cmd>Git write<CR>", { desc = "Git write" })
        end,
    },
})

-- Grepper
packle.add({
    src = "https://github.com/mhinz/vim-grepper",
    after = function()
        -- Grepper settings and shortcuts
        vim.g.grepper = {
            quickfix = 1,
            open = 1,
            switch = 0,
            jump = 0,
            tools = { "git", "rg", "ag", "ack", "pt", "grep" },
            dir = "repo,cwd",
        }

        -- Override Todo command to use Grepper
        vim.api.nvim_create_user_command("Todo", ":Grepper -noprompt -query TODO", { desc = "Search for TODO tags" })

        -- Make some shortands for various grep programs
        if vim.fn.executable("rg") == 1 then
            vim.api.nvim_create_user_command("Rg", ":GrepperRg <args>", { nargs = "+", desc = "Ripgrep" })
        end
        if vim.fn.executable("ag") == 1 then
            vim.api.nvim_create_user_command("Ag", ":GrepperAg <args>", { nargs = "+", desc = "Silversearcher" })
        end
        if vim.fn.executable("ack") == 1 then
            vim.api.nvim_create_user_command("Ack", ":GrepperAck <args>", { nargs = "+", desc = "Ack search" })
        end
    end,
})

-- quicklist customization
packle.add({
    {
        src = "https://github.com/stevearc/quicker.nvim",
        version = vim.version.range("^1"),
        after = function()
            require("quicker").setup()
            utils.keymap_set("n", "<F6>", function()
                require("quicker").toggle()
            end, { desc = "Toggle quickfix" })
            utils.keymap_set("n", "<F7>", function()
                require("quicker").toggle({ loclist = true })
            end, { desc = "Toggle loclist" })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "qf",
                callback = function()
                    utils.try_require("quicker", function(quicker)
                        utils.keymap_set("n", ">", function()
                            quicker.expand({ before = 2, after = 2, add_to_existing = true })
                        end, { desc = "Expand quickfix context", buffer = true })
                        utils.keymap_set("n", "<", function()
                            quicker.collapse()
                        end, { desc = "Collapse quickfix context", buffer = true })
                        utils.keymap_set("n", "<C-r>", function()
                            quicker.refresh()
                        end, { desc = "Refresh quickfix context", buffer = true })
                    end)
                end,
            })
        end,
    },
})

packle.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        -- Consider https://github.com/arborist-ts/arborist.nvim in the future
        -- I don't like that the plugin enables executing code downloaded from
        -- other sources, but I guess I could pin the commit too.

        -- Plugin is archived, pinning until it breaks
        version = "4916d6592ede8c07973490d9322f187e07dfefac",
        dependencies = {
            "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
        },
        after = function()
            utils.require_with_local("config.plugins.treesitter").setup()
        end,
    },
})

packle.add({
    {
        -- Make it easier to discover some of my keymaps
        src = "https://github.com/folke/which-key.nvim",
        version = vim.version.range("^3"),
        after = function()
            -- Ignore warnings about config. Turn these on when switching major versions
            require("which-key").setup({
                notify = false,
                icons = {
                    mappings = require("config.icons").nerd_font,
                },
            })
            utils.keymap_set("n", "<leader>?", function()
                require("which-key").show({ global = false })
            end, { desc = "Buffer Local Keymaps (which-key)" })
        end,
    },
})

packle.add({
    src = "https://github.com/paradoxical-dev/zeal.nvim",
    after = function()
        require("zeal").setup({
            ft_map = {
                go = { "go" },
                lua = { "lua_5.5" },
                python = { "python_3" },
                rust = { "rust" },
            },
        })
    end,
})

packle.add({
    src = "https://github.com/mhinz/vim-startify",
    after = function()
        require("utils").require_with_local("config.plugins.startify")
    end,
    dependencies = {
        -- Plenary isn't used by startify, but it is used in my config
        { "https://github.com/nvim-lua/plenary.nvim" },
    },
})

-- Using ui2 rather than this for now
--[[
-- nvim notify
packle.add({
    "https://github.com/rcarriga/nvim-notify",
})
require("config.plugins.notify")
--]]

packle.add(require("config.plugins.obsidian"))
packle.add(require("config.plugins.language_servers"))
packle.add(require("config.plugins.dap"))
packle.add(require("config.plugins.llm_assist"))

packle.apply()

-- This should run after all the LSP plugins are installed
require("config.plugins.lsp").setup()
