-- Do all Packer stuff
utils = require("utils")

local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.cmd "packadd packer.nvim"
end

-- Requires :PackerCompile for "config" to be loaded

-- Configures dark-notify to use colors from my environment
local function config_dark_notify()
    local default_color = "solarized"
    local env_color = utils.env_default("VIM_COLOR", default_color)
    require("dark_notify").run{
        schemes = {
            dark = utils.env_default("VIM_COLOR_DARK", env_color),
            light = utils.env_default("VIM_COLOR_LIGHT", env_color),
        },
        onchange = function(mode)
            -- Update lualine with new colors
            local lualine_theme = vim.g.colors_name
            if lualine_theme == "solarized" then
                lualine_theme = lualine_theme .. "_" .. mode
            end
            require("plugins.lualine").config_lualine(lualine_theme)
        end,
    }
end

return require('packer').startup(function()
    use "wbthomason/packer.nvim"

    -- Quality of life
    use "tpope/vim-endwise"
    use "tpope/vim-eunuch"
    use "tpope/vim-repeat"
    use "tpope/vim-rsi"
    use "tpope/vim-surround"
    use "tpope/vim-vinegar"
    use "vim-scripts/file-line"
    use "ludovicchabant/vim-gutentags"
    use {
        "tomtom/tcomment_vim",
        config = function()
            vim.api.nvim_set_keymap("n", "//", ":TComment<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("v", "//", ":TCommentBlock<CR>", {silent=true, noremap=true})
        end,
    }
    use {
        "FooSoft/vim-argwrap",
        config = function()
            vim.api.nvim_set_keymap("n","<Leader>a", ":ArgWrap<CR>", {silent=true, noremap=true})
        end,
    }
    use {
        "tpope/vim-fugitive",
        -- cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
    }
    use {
        "milkypostman/vim-togglelist",
        config = function()
            vim.api.nvim_set_keymap("n", "<F6>", ":call ToggleQuickfixList()<CR>", {silent=true, noremap=true})
            vim.api.nvim_set_keymap("n", "<F7>", ":call ToggleLocationList()<CR>", {silent=true, noremap=true})
        end,
    }

    -- UI
    use "~/workspace/ez-colors.nvim/wombat"
    use {
        "~/workspace/wombuddy",
        requires = "tjdevries/colorbuddy.vim",
    }
    use "vim-scripts/wombat256.vim"
    use "ishan9299/nvim-solarized-lua"
    use {
        "norcalli/nvim-colorizer.lua",
        config = function() require("colorizer").setup() end,
    }
    use "folke/tokyonight.nvim"
    --[[
    use {
        "shaunsingh/solarized.nvim",
        config = function() vim.g.colors_name = "solarized" end,
        -- config = function() require("solarized").set() end,
    }
    --]]
    --[[
    use {
        "altercation/vim-colors-solarized",
        -- config = function() update_colors() end,
        -- config = function() vim.g.colors_name = "solarized" end,
    }
    --]]
    --[[
    use {
        "vim-airline/vim-airline",
        config = function() require("plugins.airline") end,
        requires = { "vim-airline/vim-airline-themes", opt = true },
    }
    --]]
    use {
        "hoob3rt/lualine.nvim",
        -- configured by dark-notify
        -- config = function() require("plugins.lualine").config_lualine("solarized") end,
    }
    use {
        "cormacrelf/dark-notify",
        -- Download latest release on install
        run = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/",
        config = config_dark_notify,
        requires = { "hoob3rt/lualine.nvim" },
    }
    use {
        'mhinz/vim-startify',
        config = function() require("utils").require_with_local("plugins.startify") end,
    }

    -- LSP
    use {
        "neovim/nvim-lspconfig",
        config = function() require("utils").require_with_local("plugins.lsp") end,
    }
    use {
        "glepnir/lspsaga.nvim",
        requires = { "neovim/nvim-lspconfig" },
    }
    --[[
    use {
        "SmiteshP/nvim-gps",
        requires = "nvim-treesitter/nvim-treesitter"
    }
    --]]

    -- Writing
    -- abolish/pencil

    -- Treesitter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function() require("utils").require_with_local("plugins.treesitter") end,
    }
    use {
        "nvim-treesitter/nvim-treesitter-refactor",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    --[[
    use {
        "nvim-treesitter/completion-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    --]]

    -- Completion
    use {
        "nvim-lua/completion-nvim",
        config = function() require("utils").require_with_local("plugins.completion") end,
    }

    -- Fuzzy Finder
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
        },
        config = function() require("plugins.telescope") end,
    }
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
            vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h %an: %s%d %C(black)%C(bold)%cr"'

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
    use "ViViDboarder/vim-forcedotcom"
    use "rust-lang/rust.vim"
    use "hsanson/vim-android"
    use {
        'sheerun/vim-polyglot',
        config = function()
            vim.g.polyglot_disabled = { "go", "rust" }
            vim.cmd([[
                augroup ansible_playbook
                    au BufRead,BufNewFile */playbooks/*.yml,*/playbooks/*.yaml set filetype=yaml.ansible
                augroup end
            ]])
        end,
    }
    --[[
    use {
        "fatih/vim-go",
        config = function()
            vim.g.go_code_completion_enabled = 0
        end,
    }
    --]]

    use {
        "dense-analysis/ale",
        config = function() require("utils").require_with_local("plugins.ale") end,
    }

    -- Debuging nvim config
    use {
        "tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    }

end)
