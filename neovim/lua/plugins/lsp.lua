-- luacheck: globals packer_plugins
local M = {}
local utils = require("utils")

function M.config_lsp_ui()
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
    for type, icon in pairs(utils.diagnostic_signs) do
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

local function get_server_capabilities(client)
    -- HACK: Support for <0.8
    if client.server_capabilities ~= nil then
        return client.server_capabilities
    end

    local capabilities = client.resolved_capabilities
    if capabilities.documentSymbolProvider == nil then
        capabilities.documentSymbolProvider = capabilities.goto_definition
    end
    if capabilities.documentFormattingProvider == nil then
        capabilities.documentFormattingProvider = capabilities.document_formatting
    end
    if capabilities.documentRangeFormattingProvider == nil then
        capabilities.documentRangeFormattingProvider = capabilities.document_range_formatting
    end
    if capabilities.documentHighlightProvider == nil then
        capabilities.documentHighlightProvider = capabilities.document_highlight
    end
    if capabilities.workspaceSymbolProvider == nil then
        -- Not sure what the legacy version of this is
        capabilities.workspaceSymbolProvider = capabilities.goto_definition
    end

    return capabilities
end

local function get_default_attach(override_capabilities)
    return function(client, bufnr)
        -- Allow overriding capabilities to avoid duplicate lsps with capabilities

        -- Using custom method to extract for <0.8 support
        local server_capabilities = get_server_capabilities(client)
        if override_capabilities ~= nil then
            server_capabilities = vim.tbl_extend("force", server_capabilities, override_capabilities or {})
        end

        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end

        local function buf_set_option(...)
            vim.api.nvim_buf_set_option(bufnr, ...)
        end

        -- Set built in features to use lsp functions (automatic in nvim-0.8)
        -- HACK: Support for <0.8
        if vim.fn.has("nvim-0.8") ~= 1 then
            buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
            if server_capabilities.documentSymbolProvider then
                buf_set_option("tagfunc", "v:lua.vim.lsp.tagfunc")
            end
            if server_capabilities.documentFormattingProvider then
                buf_set_option("formatexpr", "v:lua.vim.lsp.formatexpr()")
            end
        end

        -- Mappings
        local opts = { noremap = true, silent = true }
        local lsp_keymap = utils.keymap_group("n", "<leader>l", opts, bufnr)
        lsp_keymap("h", "<cmd>lua vim.lsp.buf.hover()<CR>")
        lsp_keymap("rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        lsp_keymap("e", "<cmd>lua vim.diagnostic.open_float()<CR>")
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

        -- Set insert keymap for signature help
        buf_set_keymap("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

        -- Older keymaps
        buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
        buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
        buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
        buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
        buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
        buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

        -- Open diagnostic on hold
        if vim["diagnostic"] ~= nil then
            vim.cmd([[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]])
        end

        -- Use IncRename if available
        if utils.try_require("inc_rename") ~= nil then
            vim.keymap.set("n", "<leader>rn", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true, buffer = true, desc = "Rename current symbol" })
        end

        -- Set some keybinds conditional on server capabilities
        if vim.fn.has("nvim-0.8") == 1 then
            buf_set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
            buf_set_keymap("v", "<leader>lf", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
            if server_capabilities.documentFormattingProvider then
                vim.cmd([[
                augroup lsp_format
                    autocmd!
                    autocmd BufWritePre *.rs,*.go,*.sh,*.lua lua vim.lsp.buf.format({async=false, timeout_ms=1000})
                augroup END
            ]])
            end
        else
            -- HACK: Support for <0.8
            buf_set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
            buf_set_keymap("n", "<leader>lfr", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
            if server_capabilities.documentFormattingProvider then
                vim.cmd([[
                augroup lsp_format
                    autocmd!
                    autocmd BufWritePre *.rs,*.go,*.sh,*.lua lua vim.lsp.buf.formatting_sync(nil, 1000)
                augroup END
            ]])
            end
        end

        -- Set autocommands conditional on server_capabilities
        if server_capabilities.documentHighlightProvider then
            vim.cmd([[
                :highlight link LspReferenceRead MatchParen
                :highlight link LspReferenceText MatchParen
                :highlight link LspReferenceWrite MatchParen
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
            if server_capabilities.documentSymbolProvider then
                buf_set_keymap("n", "<leader>t", "<cmd>Telescope lsp_document_symbols<CR>", opts)
            end
            if server_capabilities.workspaceSymbolProvider then
                buf_set_keymap("n", "<leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
            end

            -- Replace some LSP bindings with Telescope ones
            if server_capabilities.definitionProvider then
                lsp_keymap("d", "<cmd>Telescope lsp_definitions<CR>")
            end
            if server_capabilities.typeDefinitionProvider then
                lsp_keymap("t", "<cmd>Telescope lsp_type_definition()<CR>")
            end
            lsp_keymap("i", "<cmd>Telescope lsp_implementations<CR>")
            lsp_keymap("r", "<cmd>Telescope lsp_references<CR>")
            lsp_keymap("A", "<cmd>Telescope lsp_code_actions<CR>")

            buf_set_keymap("n", "<leader>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
            buf_set_keymap("v", "<leader>lA", "<cmd>Telescope lsp_range_code_actions<CR>", opts)
        end

        -- Attach navic for statusline location
        if server_capabilities.documentSymbolProvider then
            utils.try_require("nvim-navic", function(navic)
                navic.attach(client, bufnr)
            end)
        end
    end
end

local function merged_capabilities()
    -- Maybe update capabilities
    local capabilities = nil
    utils.try_require("cmp-nvim-lsp", function(cmp_nvim_lsp)
        capabilities = cmp_nvim_lsp.default_capabilities()
    end)

    return capabilities
end

function M.config_lsp()
    utils.try_require("lspconfig", function(lsp_config)
        local capabilities = merged_capabilities()
        local default_attach = get_default_attach()
        local default_setup = { capabilities = capabilities, on_attach = default_attach }

        -- Configure each server
        lsp_config.bashls.setup(default_setup)
        lsp_config.gopls.setup(default_setup)
        lsp_config.pyright.setup(default_setup)
        lsp_config.rls.setup({
            capabilities = capabilities,
            on_attach = default_attach,
            settings = {
                rust = {
                    build_on_save = false,
                    all_features = true,
                    unstable_features = true,
                },
            },
        })

        -- Configure neovim dev for when sumneko_lua is installed
        utils.try_require("neodev", function(neodev)
            neodev.setup({})
        end)

        -- Auto setup mason installed servers
        utils.try_require("mason-lspconfig", function(mason_lspconfig)
            -- Get list of servers that are installed but not set up
            local already_setup
            if lsp_config["util"] and lsp_config.util["available_servers"] then
                already_setup = lsp_config.util.available_servers()
            else
                -- HACK: For lspconfig versions lower than 0.1.4
                already_setup = lsp_config.available_servers()
            end
            local needs_setup = vim.tbl_filter(function(server)
                return not vim.tbl_contains(already_setup, server)
            end, mason_lspconfig.get_installed_servers())

            -- Setup each server with default config
            vim.tbl_map(function(server)
                lsp_config[server].setup(default_setup)
            end, needs_setup)
        end)

        -- Config null-ls after lsps so we can disable for languages that have language servers
        require("plugins.null-ls").configure(default_setup)
    end)
end

function M.config_lsp_intaller()
    utils.try_require("mason", function(mason)
        mason.setup()
    end)
    utils.try_require("mason-lspconfig", function(mason_lspconfig)
        mason_lspconfig.setup()
    end)
end

return M
