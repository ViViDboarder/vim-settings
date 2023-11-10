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
    "https://github.com/wbthomason/packer.nvim",
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
    "https://github.com/vim-scripts/wombat256.vim",
    {
        "https://github.com/ViViDboarder/wombat.nvim",
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
    {
        "https://github.com/ViViDboarder/wombuddy.nvim",
        requires = "https://github.com/tjdevries/colorbuddy.vim",
    },
    {
        "https://github.com/ishan9299/nvim-solarized-lua",
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            ["<0.7.0"] = "faba49b",
        }),
    },
    {
        "https://github.com/folke/tokyonight.nvim",
        run = 'fish -c \'echo "set --path --prepend fish_themes_path "(pwd)"/extras" > ~/.config/fish/conf.d/tokyonight.fish\' || true', -- luacheck: no max line length
    },
})

-- Auto and ends to some ifs and dos
use("https://github.com/tpope/vim-endwise")

-- Unix commands from vim? Yup!
use("https://github.com/tpope/vim-eunuch")

-- Adds repeats for custom motions
use("https://github.com/tpope/vim-repeat")

-- Readline shortcuts
use("https://github.com/tpope/vim-rsi")

-- Surround motions
use("https://github.com/tpope/vim-surround")

-- Better netrw
use("https://github.com/tpope/vim-vinegar")

-- Easier jumping to lines
use("https://github.com/vim-scripts/file-line")

-- Auto ctags generation
use("https://github.com/ludovicchabant/vim-gutentags")

-- Make it easier to discover some of my keymaps
use({
    "https://github.com/folke/which-key.nvim",
    config = function()
        require("plugins.whichkey").configure()
    end,
    tag = "v1.*",
})

-- Better commenting
use({
    "https://github.com/tomtom/tcomment_vim",
    config = function()
        require("utils").keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
        require("utils").keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })
    end,
})

-- Allow wrapping and joining of arguments across multiple lines
use({
    "https://github.com/FooSoft/vim-argwrap",
    config = function()
        require("utils").keymap_set("n", "<Leader>a", "<cmd>ArgWrap<CR>", {
            desc = "Wrap or unwrap arguments",
        })
    end,
})

-- Adds git operations to vim
use({
    "https://github.com/tpope/vim-fugitive",
    tag = utils.map_version_rule({
        [">=0.9.2"] = utils.nil_val,
        -- HACK: Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
        -- when used in status line.
        ["<0.9.2"] = "v3.6",
    }),
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
    "https://github.com/milkypostman/vim-togglelist",
    config = function()
        require("utils").keymap_set("n", "<F6>", ":call ToggleQuickfixList()<CR>", { desc = "Toggle quickfix" })
        require("utils").keymap_set("n", "<F7>", ":call ToggleLocationList()<CR>", { desc = "Toggle location list" })
    end,
})

-- Find text everywhere!
use({
    "https://github.com/mhinz/vim-grepper",
    config = function()
        require("plugins.grepper")
    end,
})

-- Highlight inline colors
use({
    "https://github.com/norcalli/nvim-colorizer.lua",
    config = function()
        require("colorizer").setup()
    end,
})

-- Custom status line
use({
    "https://github.com/SmiteshP/nvim-gps",
    requires = "https://github.com/nvim-treesitter/nvim-treesitter",
    disable = vim.fn.has("nvim-0.7.0") == 1,
})
-- Replaces gps for 0.7+
use({
    "https://github.com/SmiteshP/nvim-navic",
    requires = "https://github.com/neovim/nvim-lspconfig",
    disable = vim.fn.has("nvim-0.7.0") ~= 1,
})

use({
    "https://github.com/nvim-lualine/lualine.nvim",
    config = function()
        require("plugins.lualine").config_lualine()
    end,
    after = vim.fn.has("nvim-0.7.0") == 1 and "nvim-navic" or "nvim-gps",
})

-- On Mac, update colors when dark mode changes
use({
    "https://github.com/cormacrelf/dark-notify",
    disable = not vim.g.is_mac,
    -- Download latest release on install
    run = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/", -- luacheck: no max line length
    config = config_dark_notify,
    requires = "https://github.com/nvim-lualine/lualine.nvim",
})

-- Custom start screen
use({
    "https://github.com/mhinz/vim-startify",
    config = function()
        require("utils").require_with_local("plugins.startify")
    end,
})

-- LSP

-- Configure language servers
use({
    "https://github.com/neovim/nvim-lspconfig",
    tag = utils.map_version_rule({
        -- [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = utils.nil_val,
        [">=0.6.1"] = "v0.1.2",
        [">=0.6.0"] = "v0.1.0",
    }),
})

-- Install language servers
use({
    "https://github.com/williamboman/mason.nvim",
    requires = {
        "https://github.com/neovim/nvim-lspconfig",
        "https://github.com/williamboman/mason-lspconfig.nvim",
    },
    -- Only supports >=0.7.0
    disable = vim.fn.has("nvim-0.7.0") ~= 1,
})

-- Lua dev for vim
use({
    "https://github.com/folke/neodev.nvim",
    requires = "https://github.com/neovim/nvim-lspconfig",
})

-- Rust analyzer
use({
    "https://github.com/simrat39/rust-tools.nvim",
    disable = vim.fn.has("nvim-0.7.0") ~= 1,
})

-- Better display of lsp diagnostics
use({
    "https://github.com/folke/trouble.nvim",
    tag = utils.map_version_rule({
        [">=0.7.2"] = "v2.*",
        ["<0.7.2"] = "v1.*",
    }),
})

-- Incremental lsp rename view
use({
    "https://github.com/smjonas/inc-rename.nvim",
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
    "https://github.com/jose-elias-alvarez/null-ls.nvim",
    branch = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = "0.7-compat",
        ["<0.7.0"] = utils.nil_val, -- use pinned commit
    }),
    commit = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = utils.nil_val, -- Use pinned branch
        [">=0.6.0"] = "4b403d2d724f48150ded41189ae4866492a8158b",
    }),
    requires = { "https://github.com/nvim-lua/plenary.nvim", "https://github.com/neovim/nvim-lspconfig" },
})

-- Writing
-- abolish/pencil
use({
    "https://github.com/preservim/vim-pencil",
    cmd = { "Pencil" },
})
use({
    "https://github.com/preservim/vim-textobj-sentence",
    requires = "https://github.com/kana/vim-textobj-user",
})
use({
    "https://github.com/junegunn/goyo.vim",
    cmd = { "Goyo", "Zen" },
    config = [[require("plugins.goyo-limelight")]],
    requires = { "https://github.com/junegunn/limelight.vim", cmd = "Limelight" },
})

-- Treesitter
use({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    commit = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = "4cccb6f494eb255b32a290d37c35ca12584c74d0",
        [">=0.6.0"] = "bc25a6a5",
    }),
    config = function()
        require("utils").require_with_local("plugins.treesitter").setup()
    end,
})
--[[ TODO: Enable this as an alterantive or fallback for LSPs
use({
    "https://github.com/nvim-treesitter/nvim-treesitter-refactor",
    requires = "https://github.com/nvim-treesitter/nvim-treesitter",
    commit = utils.map_version_rule({
        [">=0.7.0"] = utils.nil_val,
        ["<0.7.0"] = "75f5895",
    }),
})
--]]
use({
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    requires = "https://github.com/nvim-treesitter/nvim-treesitter",
    commit = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        [">=0.7.0"] = "8673926519ea61069f9c1366d1ad1949316d250e",
        ["<0.7.0"] = "eca3bf30334f85259d41dc060d50994f8f91ef7d",
    }),
})

-- Completion
use({
    "https://github.com/L3MON4D3/LuaSnip",
    tag = "v1.*",
})

use({
    "https://github.com/hrsh7th/nvim-cmp",
    config = function()
        require("plugins.completion").config_cmp()
    end,
    commit = utils.map_version_rule({
        [">=0.7.0"] = utils.nil_val,
        [">=0.5.0"] = "bba6fb67fdafc0af7c5454058dfbabc2182741f4",
    }),
    requires = {
        {
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            after = "nvim-cmp",
            commit = utils.map_version_rule({
                [">=0.7.0"] = utils.nil_val,
                ["<0.7.0"] = "3cf38d9c957e95c397b66f91967758b31be4abe6",
            }),
        },
        { "https://github.com/hrsh7th/cmp-buffer", after = "nvim-cmp" },
        { "https://github.com/f3fora/cmp-spell", after = "nvim-cmp" },
        {
            "https://github.com/saadparwaiz1/cmp_luasnip",
            after = "nvim-cmp",
            commit = utils.map_version_rule({
                [">0.7.0"] = utils.nil_val,
                [">=0.5.0"] = "b10829736542e7cc9291e60bab134df1273165c9",
            }),
        },
        "https://github.com/L3MON4D3/LuaSnip",
    },
    event = "InsertEnter *",
})

-- Add snippets
use({
    "https://github.com/rafamadriz/friendly-snippets",
    requires = "https://github.com/L3MON4D3/LuaSnip",
    after = "LuaSnip",
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end,
})

use({
    "https://github.com/ray-x/lsp_signature.nvim",
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
    "https://github.com/nvim-telescope/telescope.nvim",
    requires = {
        "https://github.com/nvim-lua/plenary.nvim",
        "https://github.com/nvim-lua/popup.nvim",
        "https://github.com/nvim-telescope/telescope-file-browser.nvim",
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
})

-- Filetypes
use("https://github.com/ViViDboarder/vim-forcedotcom")
use("https://github.com/hsanson/vim-android")
use({
    "https://github.com/sheerun/vim-polyglot",
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
    "https://github.com/tweekmonster/startuptime.vim",
    cmd = { "StartupTime" },
})

-- Fancy todo highlighting
use({
    "https://github.com/folke/todo-comments.nvim",
    requires = {
        "https://github.com/nvim-lua/plenary.nvim",
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
    "https://github.com/rcarriga/nvim-notify",
    config = function()
        require("plugins.notify")
    end,
})

use({
    "https://github.com/stevearc/dressing.nvim",
    branch = utils.map_version_rule({
        [">=0.8.0"] = utils.nil_val,
        ["<0.8.0"] = "nvim-0.7",
    }),
    config = function()
        require("dressing").setup({})
    end,
})

-- Obsidian notes
-- This loads an Obsidian plugin for better vault interraction as well as auto pulls
-- and commits to my vault git repo. On iOS devices, I use Working Copy to sync the
-- repo and use Shortcuts to automate pulling on open and auto committing and pushing
-- after closing Obsidian.
use({
    "https://github.com/epwalsh/obsidian.nvim",
    requires = {
        "https://github.com/nvim-lua/plenary.nvim",
        {
            -- Fork of https://github.com/declancm/git-scripts.nvim is used here
            -- because it inclueds a few small fixes.
            "https://github.com/vividboarder/git-scripts.nvim",
            branch = "dev",
            config = function()
                local gs = require("git-scripts")
                gs.setup({
                    default_keymaps = false,
                    commit_on_save = true,
                })
                gs.async_pull()
            end,
            after = "obsidian.nvim",
        },
    },
    tag = "v1.*",
    config = function()
        require("obsidian").setup({
            workspaces = {
                name = "personal",
                path = "~/Documents/Obsidian",
            },
        })
    end,
    event = {
        "BufRead " .. vim.fn.expand("~") .. "/Documents/Obsidian/**.md",
        "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Obsidian/**.md",
    },
})

-- Work things
-- Sourcegraph
use({
    "https://github.com/sourcegraph/sg.nvim",
    run = "nvim -l build/init.lua",
    requires = {
        "https://github.com/nvim-lua/plenary.nvim",
    },
})

-- Auto sync after bootstrapping on a fresh box
if packer_bootstrap ~= "" then
    packer.sync()
end
