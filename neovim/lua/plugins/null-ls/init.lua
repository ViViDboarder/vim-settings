local M = {}
local utils = require("utils")

function M.configure(options)
    utils.try_require("null-ls", function(null_ls)
        -- Load newer versions of plugins
        local alex = require("plugins.null-ls.linters").alex
        local ansiblelint = require("plugins.null-ls.linters").ansiblelint

        -- Use ansiblelint for only ansible files
        -- null_ls.builtins.diagnostics.ansiblelint.filetypes = { "yaml.ansible" }

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
            null_ls.builtins.formatting.gofmt,
            -- Text
            null_ls.builtins.code_actions.proselint,
            null_ls.builtins.diagnostics.proselint,
            null_ls.builtins.diagnostics.write_good,
            -- null_ls.builtins.diagnostics.alex
            alex,
            -- Ansible
            -- null_ls.builtins.diagnostics.ansiblelint,
            ansiblelint,
            -- Shell
            null_ls.builtins.diagnostics.shellcheck,
            -- Rust
            null_ls.builtins.formatting.rustfmt,
            -- Lua
            null_ls.builtins.diagnostics.luacheck,
            null_ls.builtins.formatting.stylua,
            -- Docker
            null_ls.builtins.diagnostics.hadolint,
        }

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
