local o, wo, bo = vim.o, vim.wo, vim.bo
map = vim.api.nvim_set_keymap

-- Helpers
-- Terminal escape a given string
local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Create an autocmd
local function autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then cmds = {cmds} end
    vim.cmd("augroup " .. group)
    if clear then vim.cmd [[au!]] end
    for _, cmd in ipairs(cmds) do vim.cmd("autocmd " .. cmd) end
    vim.cmd [[augroup END]]
end

-- Detect if the current system is macOS
local function is_mac()
    local has = vim.fn.has
    return (has("mac") or has("macunix") or has("gui_macvim") or vim.fn.system("uname"):find("^darwin") ~= nil)
end

-- Get env value or use default, if not present
function env_default(name, def)
    val = vim.env[name]
    return val == nil and def or val
end

vim.g.is_mac = is_mac()

-- Set leader to space
vim.g.mapleader = " "

o.termguicolors = true
o.number = true
o.expandtab = true
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.virtualedit = "onemore"
o.scrolljump = 5
o.scrolloff = 3
-- o.term = "xterm-256color"
-- o.backspace = "2"

-- Keymaps

-- Modify visual presentation
local opt_silent = {silent=true}
local opt_default = {silent=true, noremap=true}
map("n", "<C-L><C-L>", ":set wrap!<CR>", opt_silent)
map("n", "<leader>lw", ":set wrap!<CR>", opt_silent)
map("n", "<C-N><C-N>", ":set invnumber<CR>", opt_silent)
map("n", "<leader>ln", ":set invnumber<CR>", opt_silent)
map("n", "<leader>/", ":set hlsearch! hlsearch?<CR>", opt_silent)
map("n", "<leader>cs", ":nohlsearch<CR>", opt_silent)

-- Save and quit typos
map("c", "WQ<CR>", "wq<CR>", opt_silent)
map("c", "Wq<CR>", "wq<CR>", opt_silent)
map("c", "W<CR>", "w<CR>", opt_silent)
map("c", "Q<CR>", "q<CR>", opt_silent)
map("c", "Q!<CR>", "q!<CR>", opt_silent)
map("c", "Qa<CR>", "qa<CR>", opt_silent)
map("c", "Qa!<CR>", "qa!<CR>", opt_silent)
map("c", "QA<CR>", "qa<CR>", opt_silent)
map("c", "QA!<CR>", "qa!<CR>", opt_silent)
map("c", "w;", "w", opt_default)
map("c", "W;", "w", opt_default)
map("c", "q;", "q", opt_default)
map("c", "Q;", "q", opt_default)

-- Paste over
map("v", "pp", "p", opt_default)
map("v", "po", '"_dP', opt_default)

-- Buffer nav
map("n", "gb", ":bnext<CR>", {})
map("n", "gB", ":bprevious<CR>", {})

-- Easy redo
map("n", "U", ":redo<CR>", opt_default)

-- Create commands
vim.cmd "command! TagsUpdate !ctags -R ."
vim.cmd "command! Todo grep TODO"

-- Use better grep programs
if vim.fn.executable('rg') == 1 then
    vim.o.grepprg = "rg --vimgrep --no-heading --color=never"
    vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
elseif vim.fn.executable('ag') == 1 then
    vim.o.grepprg = "ag --vimgrep --nogroup --nocolor"
elseif vim.fn.executable('ack') == 1 then
    vim.o.grepprg = "ack"
end

-- Set colorscheme
-- vim.g.colors_name = "solarized"

-- Plugins
-- require("plugins")
local execute = vim.api.nvim_command

local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path})
  execute "packadd packer.nvim"
end

-- Requires :PackerCompile for "config" to be loaded

vim.lsp.set_log_level("debug")

local function config_lsp()
    local language_servers = {
        "bashls",
        "gopls",
        "pylsp",
        "rust_analyzer",
    }
    local lsp_config = require("lspconfig")

    local function default_attach(client, bufnr)
        require('completion').on_attach()

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
        local opts = { noremap=true, silent=true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
            buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
            vim.cmd([[
                augroup lsp_format
                    autocmd!
                    " autocmd BufWritePre *.rs,*.go lua vim.lsp.buf.formatting_sync(nil, 1000)
                    autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
                augroup END
            ]])
        elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        end

        -- Set autocommands conditional on server_capabilities
        if client.resolved_capabilities.document_highlight then
            vim.cmd([[
            :hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
            :hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
            :hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
            augroup lsp_document_highlight
            autocmd!
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
            ]])
        end

        -- Some override telescope bindings
        buf_set_keymap("n", "<leader>t", "<cmd>Telescope lsp_document_symbols<CR>", opts)
        buf_set_keymap("n", "<leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
    end

    for _, ls in ipairs(language_servers) do
        lsp_config[ls].setup{
            on_attach=default_attach,
            settings={
                pylsp={
                    configurationSources = {"flake8"},
                    formatCommand = {"black"},
                },
            },
        }
    end
end

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
        return t"<C-n>"
    else
        -- TODO: Switch if using compe
        return t"<Plug>(completion_trigger)"
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
            lualine_y = { "progress" },
            lualine_z = {
                { "diagnostics", sources = { "nvim_lsp" } },
                "location"
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

-- TODO: Determine if I want to keep this or remove it in favor of dark-notify
_G.update_colors = function()
    local function maybe_set(scope, name, val)
        if vim[scope][name] ~= val then
            vim[scope][name] = val
            return true
        end
        return false
    end

    -- Set colorscheme based on env
    local default_color = "solarized"
    local env_color = env_default("VIM_COLOR", default_color)

    -- Set background from dark mode
    local darkmode = vim.env.IS_DARKMODE
    if vim.g.is_mac == 1 then
        cmd = "defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light"
        darkmode = vim.fn.system(cmd):gsub("\n", ""):lower()
    end

    local change = false
    if darkmode == "dark" then
        env_color = env_default("VIM_COLOR_DARK", env_color)
        change = maybe_set("o", "background", "dark")
        change = maybe_set("g", "colors_name", env_color) or change
    elseif darkmode == "light" then
        env_color = env_default("VIM_COLOR_LIGHT", env_color)
        change = maybe_set("o", "background", "light")
        change = maybe_set("g", "colors_name", env_color) or change
    end

    if change and vim.fn.exists(":AirlineRefresh") == 1 then
        vim.cmd(":AirlineRefresh")
    end

    return changed and "Changed color to " .. env_color .. " with mode " .. darkmode or "No change"
end
-- autocmd("auto_colors", "FocusGained * call v:lua.update_colors()")

-- Initial set of colors
-- TODO: if update_colors() is removed, use the env color fetching and set the colorscheme here
update_colors()


local function config_dark_notify()
    local default_color = "solarized"
    local env_color = env_default("VIM_COLOR", default_color)
    require("dark_notify").run{
        schemes = {
            dark = env_default("VIM_COLOR_DARK", env_color),
            light = env_default("VIM_COLOR_LIGHT", env_color),
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
        config = config_lsp,
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
