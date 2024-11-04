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

function M.get_default_attach(override_capabilities)
    return function(client, bufnr)
        -- Allow overriding capabilities to avoid duplicate lsps with capabilities

        -- Using custom method to extract for <0.8 support
        local server_capabilities = client.server_capabilities
        if override_capabilities ~= nil then
            server_capabilities = vim.tbl_extend("force", server_capabilities, override_capabilities or {})
        end

        -- Mappings
        local lsp_keymap = utils.curry_keymap("n", "<leader>l", { buffer = bufnr, group_desc = "LSP" })
        lsp_keymap("h", vim.lsp.buf.hover, { desc = "Display hover" })
        lsp_keymap("rn", vim.lsp.buf.rename, { desc = "Refactor rename" })
        lsp_keymap("e", vim.diagnostic.open_float, { desc = "Open float dialog" })
        lsp_keymap("D", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        lsp_keymap("d", vim.lsp.buf.definition, { desc = "Go to definition" })
        lsp_keymap("t", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
        lsp_keymap("i", vim.lsp.buf.implementation, { desc = "Show implementations" })
        lsp_keymap("s", vim.lsp.buf.signature_help, { desc = "Show signature help" })
        lsp_keymap("wa", vim.lsp.buf.add_workspace_folder, { desc = "Workspace: Add folder" })
        lsp_keymap("wr", vim.lsp.buf.remove_workspace_folder, { desc = "Workspace: Remove folder" })
        lsp_keymap("wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { desc = "Workspace: List folders" })
        lsp_keymap("r", vim.lsp.buf.references, { desc = "References" })
        lsp_keymap("p", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
        lsp_keymap("n", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
        if server_capabilities.codeActionProvider then
            lsp_keymap("A", vim.lsp.buf.code_action, { desc = "Select code actions" })
            lsp_keymap("A", vim.lsp.buf.code_action, { mode = "v", desc = "Select code actions" })
        end

        -- Set insert keymap for signature help
        utils.keymap_set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Show signature help" })

        -- Some top level aliases or remaps
        utils.keymap_set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Display hover" })
        utils.keymap_set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
        utils.keymap_set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
        utils.keymap_set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Refactor rename" })
        utils.keymap_set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous diagnostic" })
        utils.keymap_set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })

        -- Open diagnostic on hold
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            pattern = "<buffer>",
            callback = function()
                vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
            end,
            group = vim.api.nvim_create_augroup("diagnostic_float", { clear = true }),
            desc = "Open float dialog on hold",
        })

        -- Use IncRename if available
        if utils.try_require("inc_rename") ~= nil then
            vim.keymap.set("n", "<leader>rn", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true, buffer = true, desc = "Rename current symbol" })
        end

        -- Set some keybinds conditional on server capabilities
        lsp_keymap("f", function()
            vim.lsp.buf.format({ async = true })
        end, { desc = "Format code" })
        lsp_keymap("f", function()
            vim.lsp.buf.format({ async = true })
        end, { mode = "v", desc = "Format selected code" })
        if server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                pattern = { "*.rs", "*.go", "*.sh", "*.lua" },
                callback = function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
                end,
                group = vim.api.nvim_create_augroup("lsp_format", { clear = true }),
                desc = "Auto format code on save",
            })
        end

        -- Set autocommands conditional on server_capabilities
        if server_capabilities.documentHighlightProvider then
            vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "MatchParen" })
            vim.api.nvim_set_hl(0, "LspReferenceText", { link = "MatchParen" })
            vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "MatchParen" })
            local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
            vim.api.nvim_create_autocmd(
                { "CursorHold" },
                { pattern = "<buffer>", callback = vim.lsp.buf.document_highlight, group = hl_group }
            )
            vim.api.nvim_create_autocmd(
                { "CursorMoved" },
                { pattern = "<buffer>", callback = vim.lsp.buf.clear_references, group = hl_group }
            )
        end

        -- Some override some fuzzy finder bindings to use lsp sources
        utils.try_require("telescope.builtin", function(telescope_builtin)
            -- Replace some Telescope bindings with LSP versions
            local telescope_keymap = utils.curry_keymap("n", "<leader>f", { buffer = bufnr, group_desc = "Finder" })
            if server_capabilities.documentSymbolProvider then
                telescope_keymap("t", telescope_builtin.lsp_document_symbols, { desc = "Find buffer tags" })
            end
            if server_capabilities.workspaceSymbolProvider then
                telescope_keymap("T", telescope_builtin.lsp_dynamic_workspace_symbols, { desc = "Find tags" })
            end

            -- Replace some LSP bindings with Telescope ones
            if server_capabilities.definitionProvider then
                lsp_keymap("d", telescope_builtin.lsp_definitions, { desc = "Find definition" })
            end
            if server_capabilities.typeDefinitionProvider then
                lsp_keymap("t", telescope_builtin.lsp_type_definitions, { desc = "Find type definition" })
            end
            lsp_keymap("i", telescope_builtin.lsp_implementations, { desc = "Find implementations" })
            lsp_keymap("r", telescope_builtin.lsp_references, { desc = "Find references" })
        end)

        -- Attach navic for statusline location
        if server_capabilities.documentSymbolProvider then
            utils.try_require("nvim-navic", function(navic)
                navic.attach(client, bufnr)
            end)
        end
    end
end

function M.merged_capabilities()
    -- Maybe update capabilities
    local capabilities = nil
    utils.try_require("cmp-nvim-lsp", function(cmp_nvim_lsp)
        capabilities = cmp_nvim_lsp.default_capabilities()
    end)

    return capabilities
end

function M.config_lsp()
    utils.try_require("lspconfig", function(lsp_config)
        local capabilities = M.merged_capabilities()
        local default_attach = M.get_default_attach()
        local default_setup = { capabilities = capabilities, on_attach = default_attach }

        local maybe_setup = function(config, options)
            -- Setup LSP config if the lsp command exists
            if vim.fn.executable(config.document_config.default_config.cmd[1]) == 1 then
                config.setup(options)
                return true
            end

            return false
        end

        -- Configure each server
        maybe_setup(lsp_config.gopls, default_setup)
        maybe_setup(lsp_config.pyright, default_setup)
        maybe_setup(lsp_config.bashls, {
            capabilities = capabilities,
            on_attach = default_attach,
            settings = {
                bashIde = {
                    -- Disable shellcheck linting because we have it enabled in null-ls
                    -- Some machines I use aren't configured with npm so bashls cannot
                    -- be relied on as the sole source of shellcheck linting.
                    shellcheckPath = "",
                },
            },
        })

        -- Set up rust analyzer (preferred) or rls
        -- NOTE: For version 0.10 or higher, rustaceanvim is initialized in ftconfig
        -- Maybe all lsp configs should be set up as part of their ftconfig
        if vim.fn.has("nvim-0.10") == 1 then
            maybe_setup(lsp_config.rust_analyzer, {
                capabilities = capabilities,
                on_attach = default_attach,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            features = "all",
                        },
                    },
                },
            })
            maybe_setup(lsp_config.rls, default_setup)
        end

        -- Configure neovim dev for when sumneko_lua is installed
        utils.try_require("neodev", function(neodev)
            local config = {}
            utils.try_require("dapui", function()
                config.plugins = { "nvim-dap-ui" }
                config.types = true
            end)
            neodev.setup(config)
        end)

        -- Auto setup mason installed servers
        utils.try_require("mason-lspconfig", function(mason_lspconfig)
            -- Get list of servers that are installed but not set up
            local already_setup = lsp_config.util.available_servers()
            local needs_setup = vim.tbl_filter(function(server)
                return not vim.tbl_contains(already_setup, server)
            end, mason_lspconfig.get_installed_servers())

            -- Setup each server with default config
            vim.tbl_map(function(server)
                if server == "lua_ls" then
                    -- Disable formatting with lua_ls because I use stylua
                    local config = vim.tbl_extend("force", default_setup, {
                        settings = {
                            Lua = {
                                format = {
                                    enable = false,
                                },
                            },
                        },
                    })
                    lsp_config[server].setup(config)
                else
                    lsp_config[server].setup(default_setup)
                end
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
