-- Do all Packer stuff
utils = require("utils")

local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.cmd "packadd packer.nvim"
end

-- Requires :PackerCompile for "config" to be loaded

local function config_ts()
    require'nvim-treesitter.configs'.setup{
        incremental_selection = { enable = true },
        -- Indent appears to be broken right now
        indent = { enable = false },
        textobjects = { enable = true },
        highlight = {
            enable = true,
            disable = {},
        },
        ensure_installed = {
            "bash",
            "css",
            "fish",
            "go",
            "gomod",
            "javascript",
            "json",
            "lua",
            "python",
            "rust",
            "yaml",
        },
    }
end

_G.complete_space = function()
    if vim.fn.pumvisible() == 1 then
        return utils.t"<C-n>"
    else
        -- TODO: Switch if using compe
        return utils.t"<Plug>(completion_trigger)"
        -- return vim.fn["compe#complete"]()
    end
end

-- TODO: Determine if keeping this
local function config_compe()
    require("compe").setup{
        enabled = true,
        autocomplete = true,
        source = {
            path = true,
            buffer = true,
            calc = true,
            tags = true,
            spell = true,
            nvim_lsp = true,
            nvim_lua = true,
        },
    }
end

-- TODO: Some issue with tags completion maybe compe is better?
local function config_complete()
    vim.o.completeopt = "menuone,noinsert,noselect"
    -- shortmess+=c
    vim.g.completion_enable_auto_popup = 0
    -- vim.api.nvim_set_keymap("i", "<C-Space>", "<Plug>(completion_trigger)", {silent=true})
    vim.api.nvim_set_keymap("i", "<C-Space>", "v:lua.complete_space()", {expr = true})
    vim.g.completion_enable_auto_paren = 1
    vim.cmd([[
        augroup completionPlugin
            autocmd BufEnter * lua require('completion').on_attach()
        augroup end
    ]])
end

-- TODO: Determine if I want to keep this or fzf
local function config_telescope()
    local actions = require("telescope.actions")
    require("telescope").setup{
        defaults = {
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
            },
            mappings = {
                i = {
                    ["<esc>"] = actions.close,
                }
            }
        }
    }
    opts = {silent=true, noremap=true}
    vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>Telescope find_files<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>Telescope buffers<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>Telescope current_buffer_tags<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>ft", "<cmd>Telescope tags<CR>", opts)
end

-- TODO: Customize mode to one letter and maybe not export as global
function config_lualine(theme_name)
    if theme_name == "wombat256mod" then
        theme_name = "wombat"
    end
    require("lualine").setup {
        options = {
            theme = theme_name,
            icons_enabled = false,
            component_separators = {"|", "|"},
            section_separators = {" ", " "},
        },
        sections = {
            lualine_a = { { "mode", lower = false } },
            lualine_b = { "branch", "diff" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress", "location" },
            lualine_z = {
                { "diagnostics", sources = { "nvim_lsp" } },
            },
        },
    }
end

-- TODO: Get rid of if airline goes
local function config_airline()
    -- Use short-form mode text
    vim.g.airline_mode_map = {
        ['__'] = '-',
        ['n']  = 'N',
        ['i']  = 'I',
        ['R']  = 'R',
        ['c']  = 'C',
        ['v']  = 'V',
        ['V']  = 'V',
        [''] = 'V',
        ['s']  = 'S',
        ['S']  = 'S',
        [''] = 'S',
        ['t']  = 'T',
    }

    -- abbreviate trailing whitespace and mixed indent
    vim.g["airline#extensions#whitespace#trailing_format"] = "tw[%s]"
    vim.g["airline#extensions#whitespace#mixed_indent_format"] = "i[%s]"
    -- Vertical separators for all
    vim.g.airline_left_sep=''
    vim.g.airline_left_alt_sep=''
    vim.g.airline_right_sep=''
    vim.g.airline_right_alt_sep=''
    vim.g["airline#extensions#tabline#enabled"] = 1
    vim.g["airline#extensions#tabline#left_sep"] = " "
    vim.g["airline#extensions#tabline#left_alt_sep"] = "|"
    -- Slimmer section z
    vim.g.airline_section_z = "%2l/%L:%2v"
    -- Skip most common encoding
    vim.g["airline#parts#ffenc#skip_expected_string"] = "utf-8[unix]"
    -- If UTF-8 symbols don't work, use ASCII
    -- vim.g.airline_symbols_ascii = 1
end

local function config_dark_notify()
    local default_color = "solarized"
    local env_color = utils.env_default("VIM_COLOR", default_color)
    require("dark_notify").run{
        schemes = {
            dark = utils.env_default("VIM_COLOR_DARK", env_color),
            light = utils.env_default("VIM_COLOR_LIGHT", env_color),
        },
        onchange = function(mode)
            local lualine_theme = vim.g.colors_name
            if lualine_theme == "solarized" then
                lualine_theme = lualine_theme .. "_" .. mode
            end
            config_lualine(lualine_theme)
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
        cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
    }

    -- UI
    use "vim-scripts/wombat256.vim"
    use "ishan9299/nvim-solarized-lua"
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
        config = config_airline,
        requires = { "vim-airline/vim-airline-themes", opt = true },
    }
    --]]
    use {
        "hoob3rt/lualine.nvim",
        -- configured by dark-notify
        -- config = function() config_lualine("auto") end,
    }
    use {
        "cormacrelf/dark-notify",
        -- Download latest release on install
        run = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/",
        config = config_dark_notify,
        requires = { "hoob3rt/lualine.nvim" },
    }

    -- LSP
    use {
        "neovim/nvim-lspconfig",
        config = function() require("plugins.lsp").config_lsp() end,
    }
    use {
        "glepnir/lspsaga.nvim",
        requires = { "neovim/nvim-lspconfig" },
    }

    -- Treesitter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = config_ts,
    }
    use {
        "nvim-treesitter/nvim-treesitter-refactor",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    use {
        "nvim-treesitter/completion-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    }

    -- Completion
    use {
        "nvim-lua/completion-nvim",
        config = config_complete,
    }

    -- Fuzzy Finder
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = config_telescope,
    }

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

    -- Debuging nvim config
    use {
        "tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    }

end)
