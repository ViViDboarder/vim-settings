-- Install packer
local utils = require("utils")
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
local packer_bootstrap = ""
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
    snapshot = utils.map_version_rule({
        [">=0.9.0"] = "latest-0.9",
        [">=0.8.0"] = "latest-0.8",
        [">=0.7.0"] = "latest-0.7",
        [">=0.6.0"] = "latest-0.6",
        [">=0.5.0"] = "latest",
    }),
    snapshot_path = packer_util.join_paths(vim.fn.stdpath("config"), "packer_snapshots"),
    display = {
        open_fn = function()
            return packer_util.float({ border = "single" })
        end,
    },
})

-- Load things faster!
if vim.fn.has("nvim-0.9.0") == 1 then
    -- Not needed on nvim 0.9+
    vim.loader.enable()
else
    use({
        "lewis6991/impatient.nvim",
        config = [[require('impatient')]],
        tag = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            [">0.6.0"] = "v0.2",
            [">=0.5.0"] = "v0.1",
        }),
    })
end

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
    {
        "ViViDboarder/wombat.nvim",
        requires = {
            {
                "rktjmp/lush.nvim",
                tag = utils.map_version_rule({
                    [">=0.7.0"] = utils.nil_val,
                    [">=0.5.0"] = "v1.0.1",
                }),
            },
        },
    },
    { "ViViDboarder/wombuddy.nvim", requires = "tjdevries/colorbuddy.vim" },
    {
        "ishan9299/nvim-solarized-lua",
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            ["<0.7.0"] = "faba49b",
        }),
    },
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
    tag = "v1.*",
})

-- Better commenting
use({
    "tomtom/tcomment_vim",
    config = function()
        require("utils").keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
        require("utils").keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })
    end,
})

-- Allow wrapping and joining of arguments across multiple lines
use({
    "FooSoft/vim-argwrap",
    config = function()
        require("utils").keymap_set("n", "<Leader>a", "<cmd>ArgWrap<CR>", {
            desc = "Wrap or unwrap arguments",
        })
    end,
})

-- Adds git operations to vim
use({
    "tpope/vim-fugitive",
    -- HACK: Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
    -- when used in status line.
    tag = "v3.6",
    config = function()
        require("utils").keymap_set("n", "gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
        require("utils").keymap_set("n", "gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
        require("utils").keymap_set("n", "gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
        require("utils").keymap_set("n", "gs", "<cmd>Git<CR>", { desc = "Git status" })
        require("utils").keymap_set("n", "gw", "<cmd>Git write<CR>", { desc = "Git write" })
    end,
})

-- Quick toggling of Location and Quickfix lists
use({
    "milkypostman/vim-togglelist",
    config = function()
        require("utils").keymap_set("n", "<F6>", ":call ToggleQuickfixList()<CR>", { desc = "Toggle quickfix" })
        require("utils").keymap_set("n", "<F7>", ":call ToggleLocationList()<CR>", { desc = "Toggle location list" })
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

use({
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig",
})

use({
    "nvim-lualine/lualine.nvim",
    config = function()
        require("plugins.lualine").config_lualine()
    end,
    after = "nvim-navic",
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
use({
    "neovim/nvim-lspconfig",
    tag = utils.map_version_rule({
        -- [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = utils.nil_val,
        [">=0.6.1"] = "v0.1.2",
        [">=0.6.0"] = "v0.1.0",
    }),
})

-- Install language servers
use({
    "williamboman/mason.nvim",
    requires = {
        "neovim/nvim-lspconfig",
        "williamboman/mason-lspconfig.nvim",
    },
})

-- Lua dev for vim
use({
    "folke/neodev.nvim",
    requires = "neovim/nvim-lspconfig",
})

-- Rust analyzer
use({
    "simrat39/rust-tools.nvim",
})

-- Better display of lsp diagnostics
use({
    "folke/trouble.nvim",
    tag = utils.map_version_rule({
        [">=0.7.2"] = "v2.*",
        ["<0.7.2"] = "v1.*",
    }),
})

-- Incremental lsp rename view
use({
    "smjonas/inc-rename.nvim",
    config = function()
        require("inc_rename").setup({
            input_buffer_type = "dressing",
        })
    end,
    -- Only supports >=0.8.0
    disable = vim.fn.has("nvim-0.8.0") ~= 1,
})

-- Generic linter/formatters in diagnostics API
use({
    "jose-elias-alvarez/null-ls.nvim",
    branch = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = "0.7-compat",
    }),
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
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
    commit = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = "4cccb6f494eb255b32a290d37c35ca12584c74d0",
    }),
    config = function()
        require("utils").require_with_local("plugins.treesitter").setup()
    end,
})
--[[ TODO: Enable this as an alterantive or fallback for LSPs
use({
    "nvim-treesitter/nvim-treesitter-refactor",
    requires = "nvim-treesitter/nvim-treesitter",
    commit = utils.map_version_rule({
        [">=0.7.0"] = utils.nil_val,
        ["<0.7.0"] = "75f5895",
    }),
})
--]]
use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    requires = "nvim-treesitter/nvim-treesitter",
})

-- Completion
use({
    "L3MON4D3/LuaSnip",
    tag = "v1.*",
})

use({
    "hrsh7th/nvim-cmp",
    config = function()
        require("plugins.completion").config_cmp()
    end,
    requires = {
        {
            "hrsh7th/cmp-nvim-lsp",
            after = "nvim-cmp",
        },
        { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
        { "f3fora/cmp-spell", after = "nvim-cmp" },
        {
            "saadparwaiz1/cmp_luasnip",
            after = "nvim-cmp",
        },
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

use({
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
        -- Follow stable release tag
        [">=0.7.0"] = "0.1.*",
    }),
    config = function()
        require("plugins.telescope")
    end,
})

-- Filetypes
use("ViViDboarder/vim-forcedotcom")
use("hsanson/vim-android")
use({
    "sheerun/vim-polyglot",
    config = function()
        -- TODO: Replace with api calls when dropping 0.6
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
    tag = utils.map_version_rule({
        [">=0.8.0"] = "stable",
        ["<0.8.0"] = utils.nil_val,
    }),
    branch = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        ["<0.8.0"] = "neovim-pre-0.8.0",
    }),
})

-- Fancy notifications
use({
    "rcarriga/nvim-notify",
    config = function()
        require("plugins.notify")
    end,
})

use({
    "stevearc/dressing.nvim",
    config = function()
        require("dressing").setup({})
    end,
})

-- Auto sync after bootstrapping on a fresh box
if packer_bootstrap ~= "" then
    packer.sync()
end
