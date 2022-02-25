-- Install packer
local utils = require("utils")
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
end
vim.cmd("packadd packer.nvim")

-- Configures dark-notify to use colors from my environment
local function config_dark_notify()
    require("dark_notify").run({
        onchange = function(_)
            -- Defined in _colors
            _G.update_colors()
        end,
    })
end

local packer = require("packer")
local packer_util = require("packer.util")
local use = packer.use

packer.init({
    -- Always load default
    snapshot = "latest",
    snapshot_path = packer_util.join_paths(vim.fn.stdpath("config"), "packer_snapshots"),
    display = {
        open_fn = function()
            return packer_util.float({ border = "single" })
        end,
    },
})

-- Load things faster!
use({ "lewis6991/impatient.nvim", config = [[require('impatient')]] })

-- Let Packer manage and lazyload itself
use({
    "wbthomason/packer.nvim",
    cmd = {
        "PackerClean",
        "PackerCompile",
        "PackerInstall",
        "PackerLoad",
        "PackerProfile",
        "PackerSnapshot",
        "PackerSnapshotDelete",
        "PackerSnapshotRollback",
        "PackerStatus",
        "PackerSync",
        "PackerUpdate",
    },
    config = [[require("plugins")]],
})

-- Colorschemes
use({
    "vim-scripts/wombat256.vim",
    { "ViViDboarder/wombat.nvim", requires = "rktjmp/lush.nvim" },
    { "ViViDboarder/wombuddy.nvim", requires = "tjdevries/colorbuddy.vim" },
    "ishan9299/nvim-solarized-lua",
    {
        "folke/tokyonight.nvim",
        run = 'fish -c \'echo "set --path --prepend fish_themes_path "(pwd)"/extras" > ~/.config/fish/conf.d/tokyonight.fish\' || true', -- luacheck: no max line length
    },
})

-- Auto and ends to some ifs and dos
use("tpope/vim-endwise")

-- Unix commands from vim? Yup!
use("tpope/vim-eunuch")

-- Adds repeats for custom motions
use("tpope/vim-repeat")

-- Readline shortcuts
use("tpope/vim-rsi")

-- Surround motions
use("tpope/vim-surround")

-- Better netrw
use("tpope/vim-vinegar")

-- Easier jumping to lines
use("vim-scripts/file-line")

-- Auto ctags generation
use("ludovicchabant/vim-gutentags")

-- Make it easier to discover some of my keymaps
use({
    "folke/which-key.nvim",
    config = function()
        require("plugins.whichkey").configure()
    end,
})

-- Better commenting
use({
    "tomtom/tcomment_vim",
    config = function()
        vim.api.nvim_set_keymap("n", "//", ":TComment<CR>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("v", "//", ":TCommentBlock<CR>", { silent = true, noremap = true })
    end,
})

-- Allow wrapping and joining of arguments across multiple lines
use({
    "FooSoft/vim-argwrap",
    config = function()
        vim.api.nvim_set_keymap("n", "<Leader>a", "<cmd>ArgWrap<CR>", { silent = true, noremap = true })
    end,
})

-- Adds git operations to vim
use({
    "tpope/vim-fugitive",
    config = function()
        local opts = { silent = true, noremap = true }
        vim.api.nvim_set_keymap("n", "gb", "<cmd>Gblame<CR>", opts)
        vim.api.nvim_set_keymap("n", "gc", "<cmd>Gcommit<CR>", opts)
        vim.api.nvim_set_keymap("n", "gd", "<cmd>Gdiff<CR>", opts)
        vim.api.nvim_set_keymap("n", "gs", "<cmd>Git<CR>", opts)
        vim.api.nvim_set_keymap("n", "gw", "<cmd>Gwrite<CR>", opts)
    end,
})

-- Quick toggling of Location and Quickfix lists
use({
    "milkypostman/vim-togglelist",
    config = function()
        vim.api.nvim_set_keymap("n", "<F6>", ":call ToggleQuickfixList()<CR>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("n", "<F7>", ":call ToggleLocationList()<CR>", { silent = true, noremap = true })
    end,
})

-- Find text everywhere!
use({
    "mhinz/vim-grepper",
    config = function()
        require("plugins.grepper")
    end,
})

-- Highlight inline colors
use({
    "norcalli/nvim-colorizer.lua",
    config = function()
        require("colorizer").setup()
    end,
})

-- Custom status line
use({ "SmiteshP/nvim-gps", requires = "nvim-treesitter/nvim-treesitter" })
use({
    "nvim-lualine/lualine.nvim",
    config = function()
        require("plugins.lualine").config_lualine()
    end,
    requires = {
        -- Show my current location in my status bar
        -- { "SmiteshP/nvim-gps", requires = "nvim-treesitter/nvim-treesitter" },
    },
    after = {
        "nvim-gps",
    },
})

-- On Mac, update colors when dark mode changes
use({
    "cormacrelf/dark-notify",
    disable = not vim.g.is_mac,
    -- Download latest release on install
    run = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/", -- luacheck: no max line length
    config = config_dark_notify,
    requires = "nvim-lualine/lualine.nvim",
})

-- Custom start screen
use({
    "mhinz/vim-startify",
    config = function()
        require("utils").require_with_local("plugins.startify")
    end,
})

-- LSP

-- Configure language servers
use("neovim/nvim-lspconfig")

-- Install language servers
use({
    "williamboman/nvim-lsp-installer",
    requires = "neovim/nvim-lspconfig",
})

-- Lua dev for vim
use("folke/lua-dev.nvim")

-- Better display of lsp diagnostics
use("folke/trouble.nvim")

-- Generic linter/formatters in diagnostics API
use({
    "jose-elias-alvarez/null-ls.nvim",
    commit = utils.map_version_rule({
        [">=0.6.0"] = nil,
        [">=0.5.1"] = "739a98c12bedaa2430c4a3c08d1d22ad6c16513e",
        [">=0.5.0"] = "3e7390735501d0507bf2c2b5c2e7a16f58deeb81",
    }),
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
})

-- Fancy LSP UIs
use({
    "glepnir/lspsaga.nvim",
    requires = "neovim/nvim-lspconfig",
    -- NOTE: Disabled because it's got issues with Neovim 0.6.0
    disable = true,
})

-- Writing
-- abolish/pencil
use({
    "preservim/vim-pencil",
    cmd = { "Pencil" },
})
use({
    "preservim/vim-textobj-sentence",
    requires = "kana/vim-textobj-user",
})
use({
    "junegunn/goyo.vim",
    cmd = { "Goyo", "Zen" },
    config = [[require("plugins.goyo-limelight")]],
    requires = { "junegunn/limelight.vim", cmd = "Limelight" },
})

-- Treesitter
use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        require("plugins.treesitter").setup()
    end,
})
use({
    "nvim-treesitter/nvim-treesitter-refactor",
    requires = "nvim-treesitter/nvim-treesitter",
})
use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    requires = "nvim-treesitter/nvim-treesitter",
})

-- Completion
use({
    "hrsh7th/nvim-cmp",
    config = function()
        require("plugins.completion").config_cmp()
    end,
    requires = {
        { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
        { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
        { "f3fora/cmp-spell", after = "nvim-cmp" },
        { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" },
        "L3MON4D3/LuaSnip",
    },
    event = "InsertEnter *",
})

-- Add snippets
use({
    "rafamadriz/friendly-snippets",
    requires = "L3MON4D3/LuaSnip",
    after = "LuaSnip",
    config = function()
        require("luasnip.loaders.from_vscode").load()
    end,
})

-- Fuzzy Finder
use({
    "nvim-telescope/telescope.nvim",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-lua/popup.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
    },
    tag = utils.map_version_rule({
        [">=0.6.0"] = nil,
        ["<0.6.0"] = "nvim-0.5.1",
        ["==0.5.0"] = "nvim-0.5.0",
    }),
    config = function()
        require("plugins.telescope")
    end,
})

-- Filetypes
use("ViViDboarder/vim-forcedotcom")
use("rust-lang/rust.vim")
use("hsanson/vim-android")
use({
    "sheerun/vim-polyglot",
    config = function()
        vim.cmd([[
                    augroup polyglot_fts
                    au BufRead,BufNewFile */playbooks/*.yml,*/playbooks/*.yaml set filetype=yaml.ansible
                    au BufRead,BufNewFile go.mod,go.sum set filetype=gomod
                augroup end
                ]])
    end,
})

-- Debuging nvim config
use({
    "tweekmonster/startuptime.vim",
    cmd = { "StartupTime" },
})

-- Fancy todo highlighting
use({
    "folke/todo-comments.nvim",
    requires = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("plugins.todo")
    end,
})

-- Fancy notifications
use({
    "rcarriga/nvim-notify",
    config = function()
        require("notify").setup({
            icons = {
                ERROR = "🔥",
                WARN = "⚠️",
                DEBUG = "🤔",
                INFO = "*",
            },
        })
        vim.notify = require("notify")
    end,
})

-- Auto sync after bootstrapping on a fresh box
if packer_bootstrap then
    packer.sync()
end
