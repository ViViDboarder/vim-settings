-- Install packer
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

-- Pin version dependent packages
local pinned_commits = {}
if vim.fn.has("nvim-0.6.0") ~= 1 then
    if vim.fn.has("nvim-0.5.1") == 1 then
        -- Last commit compatible with 0.5.1
        pinned_commits["telescope"] = "80cdb00b221f69348afc4fb4b701f51eb8dd3120"
    elseif vim.fn.has("nvim-0.5.0") == 1 then
        -- Last commit compatible with 0.5.1
        pinned_commits["telescope"] = "587a10d1494d8ffa1229246228f0655db2f0a48a"
    end
end

return require("packer").startup(function(use)
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
            vim.api.nvim_set_keymap("n", "<Leader>a", ":ArgWrap<CR>", { silent = true, noremap = true })
        end,
    })

    -- Adds git operations to vim
    use({
        "tpope/vim-fugitive",
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

    -- Better display of diagnostics
    use("folke/trouble.nvim")

    -- Generic linter/formatters in diagnostics API
    use({
        "jose-elias-alvarez/null-ls.nvim",
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
            require("utils").require_with_local("plugins.treesitter")
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
    --[[
    use {
        "nvim-treesitter/completion-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    --]]

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

    -- Fuzzy Finder
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-lua/popup.nvim",
        },
        commit = pinned_commits["telescope"],
        config = function()
            require("plugins.telescope")
        end,
    })
    --[[
    use {
        'junegunn/fzf',
        run = ":call fzf#install()",
    }
    use {
        'junegunn/fzf.vim',
        requires = "junegunn/fzf",
        config = function()
            vim.g.fzf_command_prefix = 'FZF'
            -- Jump to existing window if possible
            vim.g.fzf_buffers_jump = 1
            -- Override key commands
            -- vim.g.fzf_action = { ['ctrl-t'] = 'tab split', ['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit', }
            -- Override git log to show authors
            vim.g.fzf_commits_log_options = --graph --color=always \z
                --format="%C(auto)%h %an: %s%d %C(black)%C(bold)%cr"

            vim.g.fzf_preview_window = {"right:50%", "ctrl-/"}

            vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>FZF<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<Leader>b", "<cmd>FZFBuffers<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<F2>", "<cmd>FZFBuffers<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<Leader>fg", "<cmd>FZFRg<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<Leader>r", "<cmd>FZFTags<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<Leader>t", "<cmd>FZFBTags<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<Leader>g", "<cmd>FZFBCommits<CR>", {silent=true, noremap=true})
        end,
    }
    use {
        "ojroques/nvim-lspfuzzy",
        requires = { "junegunn/fzf", "junegunn/fzf" },
        config = function()
            require("lspfuzzy").setup{
                fzf_trim = false,
            }
        end,
    }
    --]]

    -- Filetypes
    use("ViViDboarder/vim-forcedotcom")
    use("rust-lang/rust.vim")
    use("hsanson/vim-android")
    use({
        "sheerun/vim-polyglot",
        config = function()
            vim.cmd([[
                augroup ansible_playbook
                    au BufRead,BufNewFile */playbooks/*.yml,*/playbooks/*.yaml set filetype=yaml.ansible
                augroup end
            ]])
        end,
    })

    use({
        "dense-analysis/ale",
        config = function()
            require("plugins.ale")
        end,
    })

    -- Debuging nvim config
    use({
        "tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    })

    -- Auto sync after bootstrapping on a fresh box
    if packer_bootstrap then
        require("packer").sync()
    end
end)
