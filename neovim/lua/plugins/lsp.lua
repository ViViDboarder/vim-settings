-- luacheck: globals packer_plugins
local M = {}
local utils = require("utils")

function M.config_lsp_ui()
    -- Add floating window boarders
    vim.cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
    vim.cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])
    local border = {
        { "┌", "FloatBorder" },
        { "─", "FloatBorder" },
        { "┐", "FloatBorder" },
        { "│", "FloatBorder" },
        { "┘", "FloatBorder" },
        { "─", "FloatBorder" },
        { "└", "FloatBorder" },
        { "│", "FloatBorder" },
    }
    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    -- Diagnostics signs
    local signs = {
        Error = "🔥",
        Warn = "⚠️",
        Hint = "🤔",
        Info = "➞",
    }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    utils.try_require("trouble", function(trouble)
        trouble.setup({
            fold_open = "▼",
            fold_closed = "▶",
            icons = false,
            use_diagnostic_signs = true,
        })
    end)
end

local function get_default_attach(override_capabilities)
    return function(client, bufnr)
        -- Allow overriding capabilities to avoid duplicate lsps with capabilities
        if override_capabilities ~= nil then
            client.resolved_capabilities = vim.tbl_extend(
                "force",
                client.resolved_capabilities,
                override_capabilities or {}
            )
        end

        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local function buf_set_option(...)
            vim.api.nvim_buf_set_option(bufnr, ...)
        end

        -- Set built in features to use lsp functions
        buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
        if client.resolved_capabilities.goto_definition then
            buf_set_option("tagfunc", "v:lua.vim.lsp.tagfunc")
        end
        if client.resolved_capabilities.document_formatting then
            buf_set_option("formatexpr", "v:lua.vim.lsp.formatexpr()")
        end

        -- Mappings
        local opts = { noremap = true, silent = true }
        local lsp_keymap = utils.keymap_group("n", "<leader>l", opts, bufnr)
        lsp_keymap("h", "<cmd>lua vim.lsp.buf.hover()<CR>")
        lsp_keymap("rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        lsp_keymap("e", "<cmd>lua vim.lsp.diagnostics.show_line_diagnostics()<CR>")
        lsp_keymap("D", "<cmd>lua vim.lsp.buf.declaration()<CR>")
        lsp_keymap("d", "<cmd>lua vim.lsp.buf.definition()<CR>")
        lsp_keymap("t", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
        lsp_keymap("i", "<cmd>lua vim.lsp.buf.implementation()<CR>")
        lsp_keymap("s", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
        lsp_keymap("wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
        lsp_keymap("wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
        lsp_keymap("wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
        lsp_keymap("r", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        lsp_keymap("p", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
        lsp_keymap("n", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

        -- Older keymaps
        buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
        buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
        buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
        buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
        buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
        buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
        buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

        -- Open diagnostic on hold
        if vim["diagnostic"] ~= nil then
            vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
        end

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
            buf_set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
            vim.cmd([[
            augroup lsp_format
                autocmd!
                autocmd BufWritePre *.rs,*.go,*.sh lua vim.lsp.buf.formatting_sync(nil, 1000)
                " autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
            augroup END
        ]])
        end
        if client.resolved_capabilities.document_range_formatting then
            buf_set_keymap("n", "<leader>lfr", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
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
        if utils.try_require("telescope") ~= nil then
            -- Replace some Telescope bindings with LSP versions
            if client.resolved_capabilities.goto_definition then
                buf_set_keymap("n", "<leader>t", "<cmd>Telescope lsp_document_symbols<CR>", opts)
                buf_set_keymap("n", "<leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
                buf_set_keymap("n", "<leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
            end

            -- Replace some LSP bindings with Telescope ones
            if client.resolved_capabilities.goto_definition then
                lsp_keymap("d", "<cmd>Telescope lsp_definitions<CR>")
                lsp_keymap("t", "<cmd>Telescope lsp_type_definition()<CR>")
            end
            lsp_keymap("i", "<cmd>Telescope lsp_implementations<CR>")
            lsp_keymap("r", "<cmd>Telescope lsp_references<CR>")
            lsp_keymap("A", "<cmd>Telescope lsp_code_actions<CR>")

            buf_set_keymap("n", "<leader>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
            buf_set_keymap("v", "<leader>lA", "<cmd>Telescope lsp_range_code_actions<CR>", opts)
        end

        -- Use LspSaga features, if possible
        if utils.is_plugin_loaded("lspsaga.nvim") then
            buf_set_keymap("n", "K", "<Cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
            buf_set_keymap("n", "<leader>rn", "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
            buf_set_keymap("n", "<leader>e", "<cmd>lua require('lspsaga.diagnostic').show_line_diagnostics()<CR>", opts)
            buf_set_keymap("n", "[d", "<cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_prev()<CR>", opts)
            buf_set_keymap("n", "]d", "<cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_next()<CR>", opts)
            buf_set_keymap("n", "<C-k>", "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
            -- Code actions
            buf_set_keymap("n", "<leader>ca", "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
        end
    end
end

local function merged_capabilities()
    -- Maybe update capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    utils.try_require("cmp-nvim-lsp", function(cmp_nvim_lsp)
        capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
    end)
    return capabilities
end

function M.config_lsp()
    utils.try_require("lspconfig", function(lsp_config)
        local capabilities = merged_capabilities()

        -- Configure each server
        lsp_config.bashls.setup({ capabilities = capabilities, on_attach = get_default_attach() })
        lsp_config.gopls.setup({ capabilities = capabilities, on_attach = get_default_attach() })
        lsp_config.pyright.setup({ capabilities = capabilities, on_attach = get_default_attach() })
        lsp_config.rls.setup({
            capabilities = capabilities,
            on_attach = get_default_attach(),
            settings = {
                rust = {
                    build_on_save = false,
                    all_features = true,
                    unstable_features = true,
                },
            },
        })

        -- Config null-ls after lsps so we can disable for languages that have language servers
        require("plugins.null-ls").configure({ capabilities = capabilities, on_attach = get_default_attach() })
    end)
end

function M.config_lsp_saga()
    utils.try_require("lspsaga", function(saga)
        saga.init_lsp_saga({
            error_sign = "🔥",
            warn_sign = "⚠️",
            hint_sign = "🤔",
            dianostic_header_icon = " 💬   ",
            code_action_icon = "💡",
            code_action_prompt = {
                enable = false,
                sign = false,
            },
        })
    end)
end

local function get_luadev_config()
    local luadev = utils.try_require("lua-dev")
    if luadev ~= nil then
        return luadev.setup({
            -- add any options here, or leave empty to use the default settings
            lspconfig = {
                on_attach = get_default_attach(),
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Disable",
                            keywordSnippet = "Disable",
                        },
                    },
                },
            },
        })
    end

    return nil
end

function M.config_lsp_intaller()
    utils.try_require("nvim-lsp-installer", function(lsp_installer)
        -- Default options
        local opts = {
            on_attach = get_default_attach(),
        }

        lsp_installer.on_server_ready(function(server)
            -- Config luadev opts
            if server.name == "sumneko_lua" then
                local luadev = get_luadev_config()
                if luadev ~= nil then
                    opts.settings = luadev.settings
                end
            end
            server:setup(opts)
        end)
    end)
end

return M
