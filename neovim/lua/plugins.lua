local utils = require("utils")
-- Lazy requires v0.8+

-- Install Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Configures dark-notify to use colors from my environment
local function config_dark_notify()
    require("dark_notify").run({
        onchange = function(_)
            -- Defined in _colors
            _G.update_colors()
        end,
    })
end

if vim.fn.has("nvim-0.9.0") == 1 then
    vim.loader.enable()
end

require("lazy").setup({
    {
        -- Load faster!
        "lewis6991/impatient.nvim",
        config = function()
            require("impatient")
        end,
        enabled = vim.fn.has("nvim-0.9.0") ~= 1,
        lazy = false,
        priority = 1001,
    },
    {
        "mhinz/vim-startify",
        config = function()
            require("utils").require_with_local("plugins.startify")
        end,
        priority = 100,
    },
    -- Colorschemes
    {
        "ViViDboarder/wombat.nvim",
        dependencies = {
            "rktjmp/lush.nvim",
        },
        lazy = false,
        priority = 1000,
    },
    {
        "ViViDboarder/wombuddy.nvim",
        dependencies = {
            "tjdevries/colorbuddy.vim",
        },
        lazy = false,
        priority = 1000,
    },
    {
        "ishan9299/nvim-solarized-lua",
        lazy = false,
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        -- TODO: Maybe not do this if already present?
        build = 'fish -c \'echo "set --path --prepend fish_themes_path "(pwd)"/extras" > ~/.config/fish/conf.d/tokyonight.fish\' || true', -- luacheck: no max line length
    },
    {
        "folke/which-key.nvim",
        config = function()
            require("plugins.whichkey").configure()
        end,
        lazy = true,
    },

    -- Auto and ends to some ifs and dos
    "tpope/vim-endwise",
    -- Unix commands from vim? Yup!
    "tpope/vim-eunuch",
    -- Adds repeats for custom motions
    "tpope/vim-repeat",
    -- Readline shortcuts
    "tpope/vim-rsi",
    -- Surround motions
    "tpope/vim-surround",
    -- Better netrw
    "tpope/vim-vinegar",
    -- Easier jumping to lines
    "vim-scripts/file-line",
    -- Auto ctags generation
    "ludovicchabant/vim-gutentags",
    {
        -- Better commenting
        "tomtom/tcomment_vim",
        config = function()
            -- TODO: use which-key for mapping
            vim.api.nvim_set_keymap("n", "//", ":TComment<CR>", { silent = true, noremap = true })
            vim.api.nvim_set_keymap("v", "//", ":TCommentBlock<CR>", { silent = true, noremap = true })
        end,
    },

    {
        -- Allow wrapping and joining of arguments across multiple lines
        "FooSoft/vim-argwrap",
        config = function()
            vim.api.nvim_set_keymap("n", "<Leader>a", "<cmd>ArgWrap<CR>", { silent = true, noremap = true })
        end,
    },
    {
        -- Adds git operations to vim
        "tpope/vim-fugitive",
        config = function()
            local opts = { silent = true, noremap = true }
            vim.api.nvim_set_keymap("n", "gb", "<cmd>Git blame<CR>", opts)
            vim.api.nvim_set_keymap("n", "gc", "<cmd>Git commit<CR>", opts)
            vim.api.nvim_set_keymap("n", "gd", "<cmd>Git diff<CR>", opts)
            vim.api.nvim_set_keymap("n", "gs", "<cmd>Git<CR>", opts)
            vim.api.nvim_set_keymap("n", "gw", "<cmd>Git write<CR>", opts)
        end,
    },
    {
        -- Quick toggling of Location and Quickfix lists
        "milkypostman/vim-togglelist",
        config = function()
            vim.api.nvim_set_keymap("n", "<F6>", ":call ToggleQuickfixList()<CR>", { silent = true, noremap = true })
            vim.api.nvim_set_keymap("n", "<F7>", ":call ToggleLocationList()<CR>", { silent = true, noremap = true })
        end,
    },
    {
        -- Find text everywhere!
        "mhinz/vim-grepper",
        config = function()
            require("plugins.grepper")
        end,
    },
    {
        -- Highlight inline colors
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },
    -- Status line
    {
        -- Custom status line
        "SmiteshP/nvim-gps",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        enabled = vim.fn.has("nvim-0.7.0") ~= 1,
        lazy = true,
    },
    {
        -- Replaces gps for 0.7+
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        enabled = vim.fn.has("nvim-0.7.0") == 1,
        lazy = true,
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("plugins.lualine").config_lualine()
        end,
    },
    {
        "cormacrelf/dark-notify",
        enabled = vim.g.is_mac,
        -- Download latest release on install
        build = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/", -- luacheck: no max line length
        config = config_dark_notify,
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
    },
    -- LSP
    {
        -- Configure language servers
        "neovim/nvim-lspconfig",
        tag = utils.map_version_rule({
            -- [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = "v0.1.6",
            [">=0.6.1"] = "v0.1.2",
            [">=0.6.0"] = "v0.1.0",
        }),
    },
    {
        -- Install language servers
        "williamboman/mason.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
        },
        -- Only supports >=0.7.0
        enabled = vim.fn.has("nvim-0.7.0") == 1,
    },
    {
        -- Lua dev for vim
        "folke/neodev.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
    },
    -- Better display of lsp diagnostics
    "folke/trouble.nvim",
    {
        -- Incremental lsp rename view
        "smjonas/inc-rename.nvim",
        --[[
        config = function()
            require("inc_rename").setup()
        end,
        --]]
        -- Only supports >=0.8.0
        enabled = vim.fn.has("nvim-0.8.0") == 1,
    },
    {
        -- Generic linter/formatters in diagnostics API
        "jose-elias-alvarez/null-ls.nvim",
        branch = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = "0.7-compat",
            ["<0.7.0"] = utils.nil_val, -- use pinned commits
        }),
        commit = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = utils.nil_val, -- Use pinned branch
            [">=0.6.0"] = "4b403d2d724f48150ded41189ae4866492a8158b",
            [">=0.5.1"] = "739a98c12bedaa2430c4a3c08d1d22ad6c16513e",
            [">=0.5.0"] = "3e7390735501d0507bf2c2b5c2e7a16f58deeb81",
        }),
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
        },
    },
    -- Writing
    {
        -- abolish/pencil
        "preservim/vim-pencil",
        cmd = { "Pencil" },
    },
    {
        "preservim/vim-textobj-sentence",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "junegunn/goyo.vim",
        cmd = { "Goyo", "Zen" },
        config = function()
            require("plugins.goyo-limelight")
        end,
        dependencies = { "junegunn/limelight.vim", cmd = "Limelight" },
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        commit = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = "4cccb6f494eb255b32a290d37c35ca12584c74d0",
            [">=0.5.0"] = "a189323454d1215c682c7ad7db3e6739d26339c4",
        }),
        config = function()
            require("utils").require_with_local("plugins.treesitter").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-refactor",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },

    {
        -- Completion
        "hrsh7th/nvim-cmp",
        config = function()
            require("plugins.completion").config_cmp()
        end,
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            [">=0.5.0"] = "bba6fb67fdafc0af7c5454058dfbabc2182741f4",
        }),
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "f3fora/cmp-spell",
            {
                "saadparwaiz1/cmp_luasnip",
                dependencies = {
                    "L3MON4D3/LuaSnip",
                },
            },
        },
        event = "InsertEnter *",
    },
    -- Add snippets
    {
        "rafamadriz/friendly-snippets",
        dependencies = { "L3MON4D3/LuaSnip" },
        -- after = "LuaSnip",
        config = function()
            require("luasnip.loaders.from_vscode").load()
        end,
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").setup({
                extra_trigger_chars = { "(", "," },
                auto_close_after = nil,
                -- Toggle these to use hint only
                floating_window = true,
                hint_enable = false,
            })
        end,
    },
    {
        -- Fuzzy Finder
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-lua/popup.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        tag = utils.map_version_rule({
            -- Follow stable release tag
            [">=0.7.0"] = "0.1.0",
            [">=0.6.0"] = "nvim-0.6",
            ["<0.6.0"] = "nvim-0.5.1",
            ["==0.5.0"] = "nvim-0.5.0",
        }),
        config = function()
            require("plugins.telescope")
        end,
    },
    -- Filetypes
    "ViViDboarder/vim-forcedotcom",
    "rust-lang/rust.vim",
    "hsanson/vim-android",
    {
        "sheerun/vim-polyglot",
        config = function()
            vim.cmd([[
            augroup polyglot_fts
            au BufRead,BufNewFile */playbooks/*.yml,*/playbooks/*.yaml set filetype=yaml.ansible
            au BufRead,BufNewFile go.mod,go.sum set filetype=gomod
            augroup end
            ]])
        end,
    },
    {
        -- Debuging nvim config
        "tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    },
    {
        -- Fancy todo highlighting
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("plugins.todo")
        end,
    },
    {
        -- Fancy notifications
        "rcarriga/nvim-notify",
        config = function()
            require("plugins.notify")
        end,
    },
}, {
    -- Use version specific lockfiles
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock-" .. utils.map_version_rule({
        [">=0.9.0"] = "0.9",
        [">=0.8.0"] = "0.8",
    }) .. ".json",
})
