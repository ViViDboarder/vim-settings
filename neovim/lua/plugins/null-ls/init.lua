local M = {}
local utils = require("utils")

local function disable_formatter_filetypes_for_existing_servers(sources, preserve)
    -- Aggregate filetypes with language servers
    local server_filetypes = {}
    utils.try_require("lspconfig", function(lsp_config)
        local available_servers
        available_servers = lsp_config.util.available_servers()
        vim.tbl_map(function(server)
            if lsp_config[server].filetypes ~= nil then
                vim.list_extend(server_filetypes, lsp_config[server].filetypes)
            end
        end, available_servers)
    end)

    -- Remove filetypes for formatters I want to preserve
    server_filetypes = vim.tbl_filter(function(ft)
        return not vim.tbl_contains(preserve or {}, ft)
    end, server_filetypes)

    local NULL_LS_FORMATTING = require("null-ls").methods.FORMATTING

    -- Apply with statement to all filtered formatters to disable filetypes
    sources = vim.tbl_map(function(builtin)
        if
            builtin.method == NULL_LS_FORMATTING
            or (type(builtin.method) == "table" and vim.tbl_contains(builtin.method, NULL_LS_FORMATTING))
        then
            return builtin.with({ disabled_filetypes = server_filetypes })
        end

        return builtin
    end, sources)

    return sources
end

function M.configure(options)
    utils.try_require("null-ls", function(null_ls)
        local sources = {
            -- Generic
            null_ls.builtins.formatting.prettier,
            -- From extras
            require("none-ls.formatting.trim_whitespace"),
            require("none-ls.formatting.trim_newlines"),
            -- Ansible
            null_ls.builtins.diagnostics.ansiblelint.with({ filetypes = { "yaml.ansible" } }),
            -- Fish
            null_ls.builtins.formatting.fish_indent,
            -- Python
            -- null_ls.builtins.formatting.reorder_python_imports,
            null_ls.builtins.formatting.isort,
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.mypy,
            -- Go
            null_ls.builtins.diagnostics.golangci_lint,
            -- Text
            null_ls.builtins.code_actions.proselint,
            null_ls.builtins.diagnostics.proselint,
            null_ls.builtins.diagnostics.alex,
            null_ls.builtins.diagnostics.write_good.with({
                extra_args = { "--no-adverb" },
                diagnostics_postprocess = function(diagnostic)
                    diagnostic.severity = vim.diagnostic.severity.WARN
                end,
            }),
            -- Shell
            -- null_ls.builtins.diagnostics.shellcheck,
            -- Lua
            null_ls.builtins.diagnostics.selene,
            null_ls.builtins.formatting.stylua,
            -- Docker
            null_ls.builtins.diagnostics.hadolint,
        }

        sources = disable_formatter_filetypes_for_existing_servers(sources, { "python", "lua" })

        -- Setup or configure null_ls
        options.sources = sources
        null_ls.setup(options)
    end)
end

return M
