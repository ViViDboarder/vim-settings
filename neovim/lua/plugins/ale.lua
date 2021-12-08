vim.g["airline#extensions#ale#enabled"] = 1
vim.g.ale_lint_on_enter = 0
vim.g.ale_go_golangci_lint_package = 1
vim.g.ale_disable_lsp = 1
vim.g.ale_linters = {
    go = {},
    rust = {},
    -- sh = {'language_server', 'shell', 'shellcheck'},
    sh = {},
    text = {"proselint", "alex"},
}
vim.g.ale_linter_aliases = {
    markdown = {"text"},
}
local pretty_trim_fixer = {
    "prettier",
    "trim_whitespace",
    "remove_trailing_lines"
}
vim.g.ale_fixers = {
    ["*"] = {"trim_whitespace", "remove_trailing_lines"},
    -- go = {"gofmt", "goimports"},
    json = pretty_trim_fixer,
    -- rust = {"rustfmt"},
    --[[
    python = {
        "black",
        "autopep8",
        "reorder-python-imports",
        "remove_trailing_lines",
        "trim_whitespace",
    },
    --]]
    markdown = pretty_trim_fixer,
    yaml = {"prettier", "remove_trailing_lines"},
    css =  pretty_trim_fixer,
    javascript = pretty_trim_fixer,
}
