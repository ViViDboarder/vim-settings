-- luacheck: globals packer_plugins
local M = {}
local utils = require("utils")

function M.config_lsp_ui()
    -- Add floating window boarders
    vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
    vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]
    local border = {
        {"┌", "FloatBorder"},
        {"─", "FloatBorder"},
        {"┐", "FloatBorder"},
        {"│", "FloatBorder"},
        {"┘", "FloatBorder"},
        {"─", "FloatBorder"},
        {"└", "FloatBorder"},
        {"│", "FloatBorder"},
    }
    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    -- Diagnostics signs
    local signs = { Error = "🔥", Warn = "⚠️", Hint = "🤔", Info = "➞" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    if utils.is_plugin_loaded("trouble") then
        require("trouble").setup {
            fold_open = "▼",
            fold_closed = "▶",
            signs = {
                error = signs.Error,
                warning = signs.Warning,
                hint = signs.Hint,
                information = signs.Info,
                other = "",
            },
        }
    end
end

local function default_attach(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    -- TODO: Maybe prefix all of these for easier discovery
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

    -- Open diagnostic on hold
    if vim["diagnostic"] ~= nil then
        vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
    end

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        vim.cmd([[
            augroup lsp_format
                autocmd!
                autocmd BufWritePre *.rs,*.go,*.sh lua vim.lsp.buf.formatting_sync(nil, 1000)
                " autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
            augroup END
        ]])
    elseif client.resolved_capabilities.document_range_formatting then
        buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
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

    -- Some override some fuzzy finder bindings to use lsp sources
    if packer_plugins["nvim-lspfuzzy"] then
        buf_set_keymap("n", "<leader>t", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
        -- buf_set_keymap("n", "<leader>ft", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    elseif packer_plugins["telescope.nvim"] then
        buf_set_keymap("n", "<leader>t", "<cmd>Telescope lsp_document_symbols<CR>", opts)
        buf_set_keymap("n", "<leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
    end

    -- Use LspSaga features, if possible
    if utils.is_plugin_loaded("lspsaga.nvim") then
        buf_set_keymap('n', 'K', "<Cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
        buf_set_keymap('n', '<leader>rn', "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
        buf_set_keymap('n', '<leader>e', "<cmd>lua require('lspsaga.diagnostic').show_line_diagnostics()<CR>", opts)
        buf_set_keymap('n', '[d', "<cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_prev()<CR>", opts)
        buf_set_keymap('n', ']d', "<cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_next()<CR>", opts)
        buf_set_keymap('n', '<C-k>', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
        -- Code actions
        buf_set_keymap('n', '<leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
    end
end

function M.config_lsp()
    local lsp_config = require("lspconfig")

    -- Maybe update capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if utils.is_plugin_loaded("cmp-nvim-lsp") then
        capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
    end

    -- Configure each server
    lsp_config.bashls.setup{ capabilities=capabilities, on_attach=default_attach }
    lsp_config.gopls.setup{ capabilities=capabilities, on_attach=default_attach }
    lsp_config.pyright.setup{ capabilities=capabilities, on_attach=default_attach }
    lsp_config.rls.setup{
        capabilities=capabilities,
        on_attach=default_attach,
        settings={
            rust={
                build_on_save = false,
                all_features = true,
                unstable_features = true,
            },
        },
    }
    if utils.is_plugin_loaded("null-ls.nvim") then
        M.config_null_ls()
        lsp_config["null-ls"].setup{ capabilities=capabilities, on_attach=default_attach }
    end
end

function M.config_lsp_saga()
    local saga = require("lspsaga")
    saga.init_lsp_saga{
        error_sign = "🔥",
        warn_sign ="⚠️",
        hint_sign = "🤔",
        dianostic_header_icon = " 💬   ",
        code_action_icon = "💡",
        code_action_prompt = {
            enable = false,
            sign = false,
        },
    }
end

function M.config_null_ls()
    local null_ls = require("null-ls")
    null_ls.setup{
        sources = {
            -- Generic
            -- null_ls.builtins.formatting.preittier,
            -- null_ls.builtins.formatting.trim_whitespace,
            -- null_ls.builtins.formatting.trim_newlines,
            -- Fish
            -- null_ls.builtins.formatting.fish_indent,
            -- Python
            null_ls.builtins.formatting.reorder_python_imports,
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.mypy,
            -- Go
            null_ls.builtins.diagnostics.golangci_lint,
            -- Text
            -- null_ls.builtins.code_actions.proselint,
            -- Ansible
            -- null_ls.builtins.diagnostics.ansiblelint,
            -- Shell
            null_ls.builtins.diagnostics.shellcheck,
            -- Rust
            -- null_ls.builtins.formatting.rustfmt,
            -- Lua
            null_ls.builtins.formatting.stylua,
        },
    }
end

return M
