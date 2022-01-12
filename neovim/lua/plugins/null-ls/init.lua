local M = {}
local utils = require("utils")

function M.configure(options)
    utils.try_require("null-ls", function(null_ls)
        -- Aggregate filetypes with language servers
        local server_filetypes = {}
        utils.try_require("lspconfig", function(lsp_config)
            vim.tbl_map(function(server)
                vim.list_extend(server_filetypes, lsp_config[server].filetypes)
            end, lsp_config.available_servers())
        end)

        -- Remove filetypes for Language servers I want to override
        local override_filetypes = { "python" }
        server_filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(override_filetypes, ft)
        end, server_filetypes)

        local sources = {
            -- Generic
            null_ls.builtins.formatting.prettier,
            null_ls.builtins.formatting.trim_whitespace,
            null_ls.builtins.formatting.trim_newlines,
            -- Fish
            null_ls.builtins.formatting.fish_indent,
            -- Python
            null_ls.builtins.formatting.reorder_python_imports,
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.mypy,
            -- Go
            null_ls.builtins.diagnostics.golangci_lint,
            -- Text
            null_ls.builtins.code_actions.proselint,
            null_ls.builtins.diagnostics.proselint,
            null_ls.builtins.diagnostics.write_good,
            -- null_ls.builtins.diagnostics.alex
            -- Ansible
            -- null_ls.builtins.diagnostics.ansiblelint.with({filetypes={"yaml.ansible"}}),
            -- Shell
            null_ls.builtins.diagnostics.shellcheck,
            -- Lua
            null_ls.builtins.diagnostics.luacheck,
            null_ls.builtins.formatting.stylua,
            -- Docker
            null_ls.builtins.diagnostics.hadolint,
        }

        -- Map disabled filetypes onto list of sources
        vim.tbl_map(function(builtin)
            return builtin.with({ disabled_filetypes = server_filetypes })
        end, sources)

        -- Add custom or modified sources
        vim.list_extend(sources, {
            require("plugins.null-ls.linters").alex,
            require("plugins.null-ls.linters").ansiblelint,
        })

        -- Setup or configure null_ls
        if null_ls["setup"] ~= nil then
            options.sources = sources
            null_ls.setup(options)
        else
            -- HACK: Handle old versions of null_ls for vim < 0.6 that don't support `setup`
            null_ls.config({ sources = sources })
            require("lspconfig")["null-ls"].setup(options)
        end
    end)
end

return M
