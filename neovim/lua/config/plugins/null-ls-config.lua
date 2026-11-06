local M = {}
local utils = require("utils")

local function disable_formatter_filetypes_for_existing_servers(sources, override)
    -- Aggregate filetypes with language servers
    local server_filetypes = {}
    local available_servers = utils.enabled_lsp_configs()

    for _, server in ipairs(available_servers) do
        if server.filetypes ~= nil and not vim.tbl_contains(override or {}, server.name) then
            vim.list_extend(server_filetypes, server.filetypes)
        end
    end

    -- Remove filetypes for formatters I want to override
    server_filetypes = vim.tbl_filter(function(ft)
        return not vim.tbl_contains(override or {}, ft)
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
            require("none-ls-shellcheck.diagnostics"),
            require("none-ls-shellcheck.code_actions"),
            -- Lua
            null_ls.builtins.diagnostics.selene,
            null_ls.builtins.formatting.stylua,
            -- Docker
            null_ls.builtins.diagnostics.hadolint,
        }

        local override = { "pyright", "basedpyright", "lua_ls" }
        sources = disable_formatter_filetypes_for_existing_servers(sources, override)

        -- Setup or configure null_ls
        options.sources = sources
        null_ls.setup(options)
    end)
end

return M
