local M = {}

local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

M.alex = {
    name = "alex",
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "markdown" },
    generator = null_ls.generator({
        command = "alex",
        args = { "--stdin", "--quiet" },
        to_stdin = true,
        from_stderr = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = helpers.diagnostics.from_patterns({
            {
                pattern = [[ *(%d+):(%d+)-(%d+):(%d+) *(%w+) *(.+) +[%w]+ +([-%l]+)]],
                groups = { "row", "col", "end_row", "end_col", "severity", "message", "code" },
            },
        }),
    }),
}

M.ansiblelint = {
    name = "ansiblelint",
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "yaml.ansible" },
    generator = null_ls.generator({
        command = "ansible-lint",
        to_stdin = true,
        ignore_stderr = true,
        args = { "-f", "codeclimate", "-q", "--nocolor", "$FILENAME" },
        format = "json",
        check_exit_code = function(code)
            return code <= 2
        end,
        multiple_files = true,
        on_output = function(params)
            local severities = {
                blocker = helpers.diagnostics.severities.error,
                critical = helpers.diagnostics.severities.error,
                major = helpers.diagnostics.severities.error,
                minor = helpers.diagnostics.severities.warning,
                info = helpers.diagnostics.severities.information,
            }
            params.messages = {}
            for _, message in ipairs(params.output) do
                local col = nil
                local row = message.location.lines.begin
                if type(row) == "table" then
                    row = row.line
                    col = row.column
                end
                table.insert(params.messages, {
                    row = row,
                    col = col,
                    message = message.check_name,
                    severity = severities[message.severity],
                    filename = message.location.path,
                })
            end
            return params.messages
        end,
    }),
}

return M
