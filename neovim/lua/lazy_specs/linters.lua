-- #selene: allow(mixed_table)
local opts = {
    linters_by_ft = {
        ansible = { "ansible_lint" },
        ["yaml.ansible"] = { "ansible_lint" },
        dockerfile = { "hadolint" },
        lua = { "selene" },
        python = { "mypy" },
        sh = { "shellcheck" },
        vim = { "vint" },
        yaml = { "yamllint" },
    },
    linters = {},
}

local events = {
    "BufEnter",
    "BufWritePost",
    "TextChanged",
    "InsertLeave",
}

return {
    "https://github.com/mfussenegger/nvim-lint",
    event = events,
    ft = vim.tbl_keys(opts.linters_by_ft),
    config = function()
        local lint = require("lint")
        -- Set custom linters from opts
        for name, linter in pairs(opts.linters) do
            lint.linters[name] = linter
        end

        -- Set linters by ft from opts
        lint.linters_by_ft = opts.linters_by_ft

        -- Create autocmd to lint on save
        local uv = vim.uv or vim.loop
        local timer = assert(uv.new_timer())
        local DEBOUNCE_MS = 500
        local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
        vim.api.nvim_create_autocmd(events, {
            group = aug,
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                timer:stop()
                timer:start(
                    DEBOUNCE_MS,
                    0,
                    vim.schedule_wrap(function()
                        if vim.api.nvim_buf_is_valid(bufnr) then
                            vim.api.nvim_buf_call(bufnr, function()
                                lint.try_lint(nil, { ignore_errors = true })
                            end)
                        end
                    end)
                )
            end,
        })
        -- Lint current file
        lint.try_lint(nil, { ignore_errors = true })
    end,
}
